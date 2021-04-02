signature CODEGEN =
sig
structure Frame : FRAME
val codegen : Frame.frame -> Tree.stm -> Assem.instr list
end


structure MIPSGen: CODEGEN = struct
structure A = Assem
structure T = Tree
structure Frame = MipsFrame 		  
		   		  
fun codegen (frame) (stm: Tree.stm) : Assem.instr list =
    let val ilist = ref (nil: A.instr list)
	val calldefs = [Frame.RA, Frame.V0, Frame.V1]@Frame.callersaves
	fun emit x= ilist := x :: !ilist
	fun result(gen) = let val t = Temp.newtemp() in gen t; t end
	fun munchArgs(i, (T.CONST c)::args) = munchArgs2(i, c, args)
	  | munchArgs(i, a)  = munchArgs3(i, a)					 
	and munchArgs3(i, [])  = []
	  | munchArgs3(i, exp::args)  = result(fn r =>
						 emit(A.OPER{assem = "move `d0, `s0\n", src = [munchExp exp], dst=[(case i of 0 => Frame.A0
                                                                                                      | 1 => Frame.A1
                                                                                                      | 2 => Frame.A2
                                                                                                      | 3 => Frame.A3)], jump = NONE}))
                                       ::munchArgs3(i+1, args)						   
	and munchArgs2(i, sl, []) = []
	  | munchArgs2(i, sl, exp::args)  =
	    result(fn r =>
		      if i < 4
		      then emit(A.OPER{assem = "move `d0, `s0\n", src = [munchExp exp], dst=[(case i of 0 => Frame.A0
												      | 1 => Frame.A1
												      | 2 => Frame.A2
												      | 3 => Frame.A3)], jump = NONE})
		      else emit(A.OPER{assem = "sw `s0, " ^ Int.toString(sl + 4 * i - 12) ^ "(`s1)\n", src = [munchExp exp, Frame.FP], dst=[], jump=NONE})) (* Assume sl is negative*)
	    ::munchArgs2(i+1, sl, args) 
	    
	and munchStm(T.SEQ(a)) = ((map munchStm a); ())  
	  | munchStm(T.MOVE(T.MEM(T.BINOP(T.PLUS,e1,T.CONST i)),e2)) =
	    emit(A.OPER{assem="sw `s1, " ^ Int.toString(i) ^ "(`s0)\n`", src=[munchExp e1, munchExp e2], dst=[],jump=NONE})
	  | munchStm(T.MOVE(T.MEM(T.BINOP(T.PLUS,T.CONST i,e1)),e2)) =
	    emit(A.OPER{assem="sw `s1, " ^ Int.toString(i) ^ "(`s0)\n", src=[munchExp e1, munchExp e2], dst=[],jump=NONE})
       (* Shouldn`t combine steps | munchStm(T.MOVE(T.MEM(e1),T.MEM(e2))) =
	    emit(A.OPER{assem="move `s1", src=[munchExp e1, munchExp e2], dst=[j,jump=NONE]})
	  | munchStm(T.MOVE(T.MEM(T.CONST i),e2)) =
	    emit(A.OPER{assem="STORE M[r0+" ^ int i ^ "] <- `s0\n", src=[munchExp e2], dst=[],jump=NONE})
	  | munchStm(T.MOVE(T.MEM(e1),e2)) =
	    emit(A.OPER{assem="STORE M[`s0] <- `s1\n", src=[munchExp e1, munchExp e2], dst= [] ,jump=NONE})*)
	  | munchStm (T.MOVE(T.TEMP t, T.CALL(T.NAME l, args)))  =	    
            emit(A.OPER{assem="jal " ^ Symbol.name(l) ^ "\nmove `d0, $v0\n", src=munchArgs(0, args), dst=t::calldefs, jump = NONE})	  
	  | munchStm (T.MOVE(T.TEMP t, T.CALL(e, args)))  =
	    emit(A.OPER{assem="jalr `s0\n move `d0, $v0\n", src=munchExp(e)::munchArgs(0, args), dst=t::calldefs, jump = NONE})
	  | munchStm (T.MOVE(T.TEMP i, T.CONST c)) =
	    emit(A.OPER{assem="addi `d0, $0, " ^ Int.toString(c) ^ "\n", src=[], dst=[i], jump = NONE})
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.PLUS,e1,T.CONST i))) =
	    emit(A.OPER{assem="addi `d0, `s0, " ^ Int.toString(i) ^ "\n", src=[munchExp e1], dst=[t], jump=NONE})
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.PLUS,T.CONST i, e1))) =
	    emit(A.OPER{assem="addi `d0, `s0, " ^ Int.toString(i) ^ "\n", src=[munchExp e1], dst=[t], jump=NONE})
          | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.PLUS,e1,e2))) =
	    emit(A.OPER{assem="add `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[t], jump=NONE})
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.MINUS,e1,e2))) =
	    emit(A.OPER{assem="sub `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[t], jump=NONE})
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.MUL,e1,e2))) =
	    emit(A.OPER{assem="mul `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[t], jump=NONE})
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.DIV,e1,e2))) =
	    emit(A.OPER{assem="div `d0, `s0, `s1\nmflo `d0", src=[munchExp e1, munchExp e2], dst=[t], jump=NONE})
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.AND,e1,e2))) =
	    emit(A.OPER{assem="and `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[t], jump=NONE})
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.OR,e1,e2))) =
	    emit(A.OPER{assem="or `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[t], jump=NONE})
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.XOR,e1,e2))) =
	    emit(A.OPER{assem="xor `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[t], jump=NONE})
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.LSHIFT,e1,e2))) =
	    emit(A.OPER{assem="sllv `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[t], jump=NONE}) 
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.RSHIFT,e1,e2))) =
	    emit(A.OPER{assem="srlv `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[t], jump=NONE}) 
	  | munchStm (T.MOVE(T.TEMP t, T.BINOP(T.ARSHIFT,e1,e2))) =
	    emit(A.OPER{assem="srav `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[t], jump=NONE}) 
          | munchStm(T.MOVE(T.TEMP i, e2) ) =
	    emit(A.MOVE{assem="move `d0, `s0\n", src=(munchExp e2), dst=i})
	  | munchStm (T.MOVE(e1, e2))  =
	    emit(A.MOVE{assem="move `d0, `s0\n", src=(munchExp e2), dst=(munchExp e1)}) (*Use1ess, only for making match exhaustive *)
  	  | munchStm (T.JUMP(T.NAME l, [lab])) =
	    emit(A.OPER{assem="j " ^ Symbol.name(lab) ^ "\n", src=[], dst=[], jump = SOME([lab])})
	  | munchStm (T.JUMP(e1, l)) =
	    emit(A.OPER{assem="jr `s0\n", src=[munchExp e1], dst=[], jump = SOME(l)})
	  | munchStm (T.CJUMP(T.EQ,e1,e2,t,f)) =
	    emit(A.OPER{assem="beq `s0, `s1, " ^ Symbol.name(t) ^ "\nbne `s0, `s1, " ^ Symbol.name(f) ^ "\n", src=[munchExp e1, munchExp e2], dst=[], jump=SOME([t,f])})
	  | munchStm (T.CJUMP(T.NE,e1,e2,t,f)) =
	    emit(A.OPER{assem="bne `s0, `s1, " ^ Symbol.name(t) ^ "\nbeq `s0, `s1, " ^ Symbol.name(f) ^ "\n", src=[munchExp e1, munchExp e2], dst=[], jump=SOME([t,f])})
	  | munchStm (T.CJUMP(T.LT,e1,e2,t,f)) =
            emit(A.OPER{assem="blt `s0, `s1, " ^ Symbol.name(t) ^ "\nbge `s0, `s1, " ^ Symbol.name(f) ^ "\n", src=[munchExp e1, munchExp e2], dst=[], jump=SOME([t,f])})
          | munchStm (T.CJUMP(T.GT,e1,e2,t,f)) =
            emit(A.OPER{assem="bgt `s0, `s1, " ^ Symbol.name(t) ^ "\nble `s0, `s1, " ^ Symbol.name(f) ^ "\n", src=[munchExp e1, munchExp e2], dst=[], jump=SOME([t,f])})
	  | munchStm (T.CJUMP(T.LE,e1,e2,t,f)) =
            emit(A.OPER{assem="ble `s0, `s1, " ^ Symbol.name(t) ^ "\nbgt `s0, `s1, " ^ Symbol.name(f) ^ "\n", src=[munchExp e1, munchExp e2], dst=[], jump=SOME([t,f])})
          | munchStm (T.CJUMP(T.GE,e1,e2,t,f)) =
            emit(A.OPER{assem="bge `s0, `s1, " ^ Symbol.name(t) ^ "\nblt `s0, `s1, " ^ Symbol.name(f) ^ "\n", src=[munchExp e1, munchExp e2], dst=[], jump=SOME([t,f])})
	  | munchStm (T.CJUMP(T.ULT,e1,e2,t,f)) =
            emit(A.OPER{assem="bltu `s0, `s1, " ^ Symbol.name(t) ^ "\nbgeu `s0, `s1, " ^ Symbol.name(f) ^ "\n", src=[munchExp e1, munchExp e2], dst=[], jump=SOME([t,f])})
          | munchStm (T.CJUMP(T.UGT,e1,e2,t,f)) =
            emit(A.OPER{assem="bgtu `s0, `s1, " ^ Symbol.name(t) ^ "\nbleu `s0, `s1, " ^ Symbol.name(f) ^ "\n", src=[munchExp e1, munchExp e2], dst=[], jump=SOME([t,f])})
          | munchStm (T.CJUMP(T.ULE,e1,e2,t,f)) =
            emit(A.OPER{assem="bleu `s0, `s1, " ^ Symbol.name(t) ^ "\nbgtu `s0, `s1, " ^ Symbol.name(f) ^ "\n", src=[munchExp e1, munchExp e2], dst=[], jump=SOME([t,f])})
          | munchStm (T.CJUMP(T.UGE,e1,e2,t,f)) =
            emit(A.OPER{assem="bgeu `s0, `s1, t \nbltu `s0, `s1, f \n", src=[munchExp e1, munchExp e2], dst=[], jump=SOME([t,f])})
	  | munchStm (T.EXP(T.CALL(T.NAME(l), args))) = 	    
            emit(A.OPER{assem="jal " ^ Symbol.name(l) ^ "\n", src=munchArgs(0,args), dst=calldefs, jump = NONE})
  	  | munchStm (T.EXP(T.CALL(e, args))) = (* somehow need to be able to list actual registers in calldefs *)
	    emit(A.OPER{assem="jalr `s0\n", src=munchExp(e)::munchArgs(0,args), dst=calldefs, jump = NONE})
	  | munchStm (T.EXP e1) =
	    emit(A.OPER{assem="add `s0, $0, `s0\n", src=[munchExp e1], dst=[], jump=NONE})		
	  | munchStm(T.LABEL lab) =
	    emit(A.LABEL{assem=Symbol.name(lab) ^ ":\n", lab=lab})
      
	and munchExp(T.ESEQ(a,b)) = (munchStm a; munchExp b)
 	  | munchExp(T.MEM(T.BINOP(T.PLUS,e1,T.CONST i))) =
	    result(fn r => emit(A.OPER{assem="lw `d0, "^ Int.toString(i) ^ "(`s0)\n", src =[munchExp e1], dst=[r], jump=NONE}))
	  | munchExp(T.MEM(T.BINOP(T.PLUS,T.CONST i,e1))) =    
	    result(fn r => emit(A.OPER{assem="lw `d0, " ^ Int.toString(i) ^ "(`s0)\n", src=[munchExp e1], dst=[r], jump=NONE}))
	  | munchExp(T.MEM(T.CONST i)) =
	    result(fn r => emit(A.OPER{assem="li `d0, " ^ Int.toString(i) ^ "\n", src=[], dst=[r], jump=NONE}))
	  | munchExp(T.MEM(e1)) =
	    result(fn r => emit(A.OPER{assem="lw `d0, 0(`s0)\n", src=[munchExp e1], dst=[r], jump=NONE}))
	  | munchExp(T.BINOP(T.PLUS,e1,T.CONST i)) =
	    result(fn r => emit(A.OPER{assem="addi `d0, `s0, " ^ Int.toString(i) ^ "\n",	src=[munchExp e1], dst=[r], jump=NONE}))
	  | munchExp(T.BINOP(T.PLUS,T.CONST i,e1)) =
	    result(fn r => emit(A.OPER{assem="addi `d0, `s0, " ^ Int.toString(i) ^ "\n", src=[munchExp e1], dst=[r], jump=NONE}))
	  | munchExp(T.CONST i) =
	    result(fn r => emit(A.OPER{assem="addi `d0, $0, " ^ Int.toString(i) ^ "\n", src=[], dst=[r], jump=NONE}))
	  | munchExp(T.BINOP(T.PLUS,e1,e2)) =
	    result(fn r => emit(A.OPER{assem="add `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.MINUS, e1, e2))  =
	    result(fn r => emit(A.OPER{assem="sub `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.MUL, e1, e2)) =
	    result(fn r => emit(A.OPER{assem="mul `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.DIV, e1, e2)) =
	    result(fn r => emit(A.OPER{assem="div `s0, `s1\nmove `d0, $lo\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.AND, e1, e2)) =
	    result(fn r => emit(A.OPER{assem="and `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.OR, e1, e2)) =
            result(fn r => emit(A.OPER{assem="or `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.XOR, e1, e2)) =
            result(fn r => emit(A.OPER{assem="xor `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))  
          | munchExp (T.BINOP(T.LSHIFT, e1, e2)) =
	    result(fn r => emit(A.OPER{assem="sllv `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.RSHIFT, e1, e2)) =
            result(fn r => emit(A.OPER{assem="srlv `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.BINOP(T.ARSHIFT, e1, e2)) =
            result(fn r => emit(A.OPER{assem="srav `d0, `s0, `s1\n", src=[munchExp e1, munchExp e2], dst=[r], jump=NONE}))
	  | munchExp (T.NAME lab) = 
	    result(fn r => emit(A.LABEL{assem=Symbol.name(lab) ^ " shouldn't have gotten here:\n", lab = lab}))
	  | munchExp(T.CALL(T.NAME l, args)) =
	    result(fn r => emit(A.OPER{assem="jal " ^ Symbol.name(l) ^ "\nmove `d1 `d0\n", src= munchArgs(0, args), dst = [Frame.RV, r]@calldefs, jump = NONE}))
	  | munchExp(T.CALL(e, args)) =	    
            result(fn r => emit(A.OPER{assem="jalr `s0\n", src=munchExp(e)::munchArgs(0, args), dst = Frame.RV::calldefs, jump = NONE})) (* SHOULDN'T GET HERE ANYWAYS *)

	  | munchExp(T.TEMP t) = t
				    		     
		     
in munchStm stm;
rev(!ilist)
end
end
				 
