signature SEMANT = 
sig
	type venvType
	type tenvType
	type expty

	val transVar: venvType * tenvType * Absyn.var -> expty
	val transExp: venvType * tenvType * Absyn.exp -> expty
	val transDec: venvType * tenvType * Absyn.dec -> {venv: venvType, tenv: tenvType}
	val transTy:         tenvType * Absyn.ty  -> Types.ty
	val transProg: Absyn.exp -> unit
end

structure Semant = 
struct

	structure A = Absyn
    structure S = Symbol
	structure T = Types
	type ty = Types.ty

	structure Translate = struct type exp = unit end
	type venvType = Env.enventry Symbol.table
	type tenvType = ty Symbol.table
	type expty = {exp: Translate.exp, ty: Types.ty}

	val stack: { tenv: tenvType, venv: venvType } list ref = ref []
	val tenv: (tenvType) ref = ref Env.base_tenv
	val venv: (venvType) ref = ref Env.base_venv
	
	fun checkInt ({exp, ty = T.INT}, pos) = ()
	  | checkInt ({exp, ty}, pos) = ErrorMsg.error pos "Not int type"
	fun checkThenElse ({exp1, ty1}, {exp2, ty2}, pos) = if ty1 = ty2 then () else ErrorMsg.error pos "Then Else disagree" (* not sure if this works *)  			       
	fun transExp (exp) = 
		let fun trexp (A.NilExp) = {exp=(), ty=T.NIL}
			  | trexp (A.IntExp(ival)) = {exp=(), ty=T.INT}
			  | trexp (A.StringExp(sval)) = {exp=(), ty=T.STRING}
			  | trexp (A.WhileExp({test, body, pos})) = (checkInt(trexp test, pos); trexp body; {exp = (), ty = T.NIL}) (* Assuming loops return null *)
			(*
			  | trexp (A.ForExp(var, escape, lo, hi, body, pos)) = (intVar(var); checkInt(lo); checkInt(hi); trexp body; {exp = (), ty = T.NIL})(* TODO define intVar *)
 			  | trexp (A.LetExp(decs, body, pos)) = (scopeDown; parseDecs; trexp body; scopeUp; {exp = (), ty = T.NIL}) (* ADD scopedown (pushstack), scopeUp (popstack), and dec parsing, also assuming returns nothing *)
			  | trexp (A.OpExp(left, oper, right, pos)) = (checkInt(trexp left, pos); checkInt(trexp right, pos); {exp=(), ty=T.INT})
			  | trexp (A.AssignExp(var, exp, pos)) = (addVar(var, (trexp exp).ty); {exp = (), ty=T.NIL}) (* should add variable to map with type second parameter *)
			  | trexp (A.SeqExp(exps)) = {exp = (), ty = foldl (fn(x, y) => (trexp x).ty) T.NIL exps} (* used foldl here to capture last type, note does not actually keep state *)
			  (* not sure what to do for callexp *)	      
			  | trexp (A.ArrayExp(typ, size, init, pos)) = (checkInt(trexp size, pos); if typ = (trexp init).ty then () else ErrorMsg.Error pos "Initializing array with wrong type"; {exp = (), ty = T.NIL})
   			  | trexp (A.RecordExp(fields, typ, pos)) = (map (fn(x) => if T.lookup(typ).lookup(#1 x) = (trexp (#2 x)).ty then () else ErrorMsg.Error pos "Wrong initialization of type in record") fields;   {exp = (), ty = typ}) (* FIXME? *)
			  | trexp (A.IfExp(test, then', else', pos))  =
			    	   case else' of NONE => (checkInt(trexp test, pos); trexp then'; {exp=(), ty=(trexp then').ty})
					| SOME exp => (checkInt(trexp test, pos); checkThenElse(trexp then', trexp else', pos); {exp = (), ty=(trexp then').ty})			   
			*)		    
  		in 
			trexp exp
		end
	fun transProg(exp) = (transExp(exp); ()) (* several questions: how do we get types for variable declarations, how do we traverse the tree so all the types are loaded, i.e. at what stage do we check for type mismatch *)
end
