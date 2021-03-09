signature SEMANT = 
sig
	type venv = Env.enventry Symbol.table
	type tenv = ty Symbol.table
	structure Translate = struct type exp = unit end
	type expty = {exp: Translate.exp, ty: Types.ty}

	val transVar: venv * tenv * Absyn.var -> expty
	val transExp: venv * tenv * Absyn.exp -> expty
	val transDec: venv * tenv * Absyn.dec -> {venv: venv, tenv: tenv}
	val transTy:         tenv * Absyn.ty  -> Types.ty
	val transProg: Absyn.exp -> unit
end

structure Semant:
	sig val transProg: Absyn.exp -> unit end = 
struct
    structure A = Absyn
    structure S = Symbol
    structure TypeTable = RedBlackMapFn (struct type ord_key = S.symbol
				    val compare = (fn(s1, s2) => Int.compare(((fn(s, n) => n) s1),((fn (s, n) => n) s2))) (* use rbmap or hashmap here? *) 
			    end)
	val stack = ref [TypeTable.empty]
	fun checkInt ({exp,T.INT}, pos) = ()
	  | checkInt ({exp, ty}, pos) = ErrorMsg.Error pos "Not int type"
	fun checkThenElse ({exp1, ty1}, {exp2, ty2}, pos) = if ty1 = ty2 then () else ErrorMsg.Error pos "Then Else disagree" (* not sure if this works *) 					    fun transProg (A.VarDec({name: S.symbol,
		     escape: bool ref,
		     typ: (S.symbol * pos) option,
		     init: exp,
		     pos: pos}
		      )) = transProg(init); (* several questions: how do we get types for variable declarations, how do we traverse the tree so all the types are loaded, i.e. at what stage do we check for type mismatch *)  			       
	fun transExp (venv, tenv, exp) = 
		let fun trexp (A.NilExp) = {exp=(), ty=T.NIL}
			  | trexp (A.IntExp(ival)) = {exp=(), ty=T.INT}
			  | trexp (A.StringExp(sval)) = {exp=(), ty=T.STRING}
			  | trexp (A.IfExp(test, then', else', pos))  =
			    case else' of NONE => (checkInt(trexp test, pos); trexp then'; {exp=(), ty=(trexp then').ty})
					| SOME exp => (checkInt(trexp test, pos); checkThenElse(trexp then', trexp else', pos); {exp = (), ty=(trexp then').ty})
			  | trexp (A.WhileExp(test, body, pos)) = (checkInt(trexp test, pos); trexp body; {exp = (), ty = (trexp body).ty})
			  | trexp (A.OpExp(left, oper, right, pos)) =
			  		case oper of A.PlusOp => (checkInt(trexp left, pos); checkInt(trexp right, pos) {exp=(), ty=T.INT})
			  		  | A.MinusOp => (checkInt(trexp left, pos); checkInt(trexp right, pos) {exp=(), ty=T.INT})
			  		  | A.TimesOp => (checkInt(trexp left, pos); checkInt(trexp right, pos) {exp=(), ty=T.INT})
			  		  | A.DivideOp => (checkInt(trexp left, pos); checkInt(trexp right, pos) {exp=(), ty=T.INT})
				          | A.LtOp => (checkInt(trexp left, pos); checkInt(trexp right, pos) {exp=(), ty=T.INT})
					  | A.GtOp  => (checkInt(trexp left, pos); checkInt(trexp right, pos) {exp=(), ty=T.INT})
					  | A.NeqOp => (checkInt(trexp left, pos); checkInt(trexp right, pos) {exp=(), ty=T.INT})
					  | A.LeOp => (checkInt(trexp left, pos); checkInt(trexp right, pos) {exp=(), ty=T.INT})
					  | A.GeOp => (checkInt(trexp left, pos); checkInt(trexp right, pos) {exp=(), ty=T.INT})
					  | A.EqOp => (checkInt(trexp left, pos); checkInt(trexp right, pos) {exp=(), ty=T.INT})
					    
  		in 
			trexp exp
		end
end
