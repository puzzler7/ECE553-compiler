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
       (* | munchStm(T.MOVE(T.MEM(el),T.MEM(e2))) =
	    emit(A.OPER{assem="move $s1", src=[munchExp el, munchExp e2], dst=[j,jump=NONE]})
	  | munchStm(T.MOVE(T.MEM(T.CONST i),e2)) =
	    emit(A.OPER{assem="STORE M[r0+" ^ int i ^ "] <- 's0\n", src=[munchExp e2], dst=[],jump=NONE})
	  | munchStm(T.MOVE(T.MEM(el),e2)) =
	    emit(A.OPER{assem="STORE M['s0] <- 'sl\n", src=[munchExp el, munchExp e2], dst= [] ,jump=NONE})*)
	  | munchStm(T.MOVE(T.TEMP i, e2) ) =
	    emit(A.OPER{assem="move $d0, $s0\n", src=[munchExp e2], dst=[i], jump=NONE})
	(*| munchStm(T.LABEL lab) =
	    emit(A.LABEL{assem=lab ^ ":\n", lab=lab})*)
      
	and munchExp(T.MEM(T.BINOP(T.PLUS,el,T.CONST i))) =
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
	  | munchExp(T.TEMP t) = t
		     
in munchStm stm;
rev(!ilist)
end
