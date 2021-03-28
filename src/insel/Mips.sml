signature CODEGEN =
sig
structure Frame : FRAME
val codegen : Frame.frame -> Tree.stm -> Assem.instr list
end


structure MIPSGen: CODEGEN = struct			
fun codegen (frame) (stm: Tree.stm) : Assem.instr list =
    let val ilist = ref (nil: A.instr list)		
	fun emit x= ilist := x :: !ilist
	fun result(gen) = let val t = Temp.newtemp() in gen t; t end
	fun munchStm(T.SEQ(a,b)) = (munchStm a; munchStm b)
	  | munchStm(T.MOVE(T.MEM(T.BINOP(T.PLUS,el,T.CONST i)),e2)) =
	    emit(A.OPER{assem="sw $s1, " ^ int i ^ "($s0)\n'", src=[munchExp el, munchExp e2], dst=[],jump=NONE})
	  | munchStm(T.MOVE(T.MEM(T.BINOP(T.PLUS,T.CONST i,el)),e2)) =
	    emit(A.OPER{assem="sw $s1, " ^ int i ^ "($s0)\n", src=[munchExp el, munchExp e2], dst=[],jump=NONE})
       (* Shouldn't combine steps | munchStm(T.MOVE(T.MEM(el),T.MEM(e2))) =
	    emit(A.OPER{assem="move $s1", src=[munchExp el, munchExp e2], dst=[j,jump=NONE]})
	  | munchStm(T.MOVE(T.MEM(T.CONST i),e2)) =
	    emit(A.OPER{assem="STORE M[r0+" ^ int i ^ "] <- 's0\n", src=[munchExp e2], dst=[],jump=NONE})
	  | munchStm(T.MOVE(T.MEM(el),e2)) =
	    emit(A.OPER{assem="STORE M['s0] <- 'sl\n", src=[munchExp el, munchExp e2], dst= [] ,jump=NONE})*)
	  | munchStm(T.MOVE(T.TEMP i, e2) ) =
	    emit(A.OPER{assem="move $d0, $s0\n", src=[munchExp e2], dst=[i], jump=NONE})
	  | munchStm (T.JUMP(T.NAME lab)) =
	    emit(A.OPER{assem="j lab", src=[], dst=[], jump = lab})
	  | munchStm (T.JUMP(e1)) =
	    emit(A.OPER{assem="jr $s0", src=[munchExp e1], dst=[], jump = NONE (* what to put? *)})
	  | munchStm (T.CJUMP(T.EQ,e1,e2,t,f)) =
	    emit(A.OPER{assem="beq $s0, $s1, t \n bne $s0, $s1, f \n", src=[munchExp e1, munchExp e2], dst=[], jump=NONE (*what to put*)})
	  | munchStm (T.CJUMP(T.NE,e1,e2,t,f)) =
	    emit(A.OPER{assem="bne $s0, $s1, t \n beq $s0, $s1, f \n", src=[munchExp e1, munchExp e2], dst=[], jump=NONE (*what to put*)})
	  | munchStm (T.CJUMP(T.LT,e1,e2,t,f)) =
            emit(A.OPER{assem="blt $s0, $s1, t \n bge $s0, $s1, f \n", src=[munchExp e1, munchExp e2], dst=[], jump=NONE (*what to put*)})
          | munchStm (T.CJUMP(T.GT,e1,e2,t,f)) =
            emit(A.OPER{assem="bgt $s0, $s1, t \n ble $s0, $s1, f \n", src=[munchExp e1, munchExp e2], dst=[], jump=NONE (*what to put*)})
	  | munchStm (T.CJUMP(T.LE,e1,e2,t,f)) =
            emit(A.OPER{assem="ble $s0, $s1, t \n bgt $s0, $s1, f \n", src=[munchExp e1, munchExp e2], dst=[], jump=NONE (*what to put*)})
          | munchStm (T.CJUMP(T.GE,e1,e2,t,f)) =
            emit(A.OPER{assem="bge $s0, $s1, t \n blt $s0, $s1, f \n", src=[munchExp e1, munchExp e2], dst=[], jump=NONE (*what to put*)})
		(* TODO : U instructions *)
	  | munchStm (T.EXP e1) =
	    emit(A.OPER{assem="add $s0, $0, $s0\n", src=[munchExp e1], dst=[], jump=NONE})		
	  | munchStm(T.LABEL lab) =
	    emit(A.LABEL{assem=lab ^ ":\n", lab=lab})
      
	and munchExp(T.ESEQ(a,b)) = (munchExp a; munchExp b)
 	  | munchExp(T.MEM(T.BINOP(T.PLUS,el,T.CONST i))) =
	    result(fn r => emit(A.OPER{assem="lw $d0, "^ int i ^ "($s0)\n", src =[munchExp el], dst=[r], jump=NONE}))
	  | munchExp(T.MEM(T.BINOP(T.PLUS,T.CONST i,el))) =    
	    result(fn r => emit(A.OPER{assem="lw $d0, " ^ int i ^ "($s0)\n", src=[munchExp el], dst=[r], jump=NONE}))
	  | munchExp(T.MEM(T.CONST i)) =
	    result(fn r => emit(A.OPER{assem="li $d0, " ^ int i  "\n", src=[], dst=[r], jump=NONE}))
	  | munchExp(T.MEM(el)) =
	    result(fn r => emit(A.OPER{assem="lw $d0, 0($s0)\n", src=[munchExp el], dst=[r], jump=NONE}))
	  | munchExp(T.BINOP(T.PLUS,el,T.CONST i)) =
	    result(fn r => emit(A.OPER{assem="addi $d0, $s0, " ^ int i ^ "\n",	src=[munchExp el], dst=[r], jump=NONE}))
	  | munchExp(T.BINOP(T.PLUS,T.CONST i,el)) =
	    result(fn r => emit(A.OPER{assem="addi $d0, $s0, " ^ int i ^ "\n", src=[munchExp el], dst=[r], jump=NONE}))
	  | munchExp(T.CONST i) =
	    result(fn r => emit(A.OPER{assem="addi $d0, $0, " ^ int i ^ "\n", src=[], dst=[r], jump=NONE}))
	  | munchExp(T.BINOP(T.PLUS,el,e2)) =
	    result(fn r => emit(A.OPER{assem="add $d0, $s0, $sl\n", src=[munchExp el, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.MINUS, e1, e2))  =
	    result(fn r => emit(A.OPER{assem="sub $d0, $s0, $s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.MUL, e1, e2)) =
	    result(fn r => emit(A.OPER{assem="mul $d0, $s0, $s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.DIV, e1, e2)) =
	    result(fn r => emit(A.OPER{assem="div $s0, $s1\n move $d0, $lo\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.AND, e1, e2)) =
	    result(fn r => emit(A.OPER{assem="and $d0, $s0, $s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.OR, e1, e2)) =
            result(fn r => emit(A.OPER{assem="or $d0, $s0, $s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.XOR, e1, e2)) =
            result(fn r => emit(A.OPER{assem="xor $d0, $s0, $s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))  
          | munchExp (T.BINOP(T.LSHIFT, e1, e2)) =
	    result(fn r => emit(A.OPER{assem="sllv $d0, $s0, $s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.RSHIFT, e1, e2)) =
            result(fn r => emit(A.OPER{assem="srlv $d0, $s0, $s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.ARSHIFT, e1, e2)) =
            result(fn r => emit(A.OPER{assem="srav $d0, $s0, $s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))

	  | munchExp(T.TEMP t) = t
				     
		     
in munchStm stm;
rev(!ilist)
end
