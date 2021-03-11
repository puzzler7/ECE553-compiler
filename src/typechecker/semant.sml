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
	fun checkArgs ([], [], pos) = ()
	  | checkArgs (a::l1, [], pos) = ErrorMsg.error pos "Insufficient arguments"
	  | checkArgs ([], b::l2, pos) = ErrorMsg.error pos "Too many arguments"
	  | checkArgs (a::l1, b::l2, pos) = if a = b then checkArgs(l1, l2, pos) else ErrorMsg.error pos "Argument type mismatch"
	fun lookup (t, v, pos) = (case S.look(t, v) of NONE => (ErrorMsg.error pos "Variable undefined"; T.NIL)
					       | SOME x => x)				       
   	fun checkInt ({exp, ty = T.INT}, pos) = ()
	  | checkInt ({exp, ty}, pos) = ErrorMsg.error pos "Not int type"
	fun scopeDown () =
	    stack := {tenv = !tenv, venv = !venv}::(!stack)
	fun scopeUp () =
	    (fn(a::l) => (tenv := #tenv(a); venv := #venv(a); stack := l)) (!stack) 
	fun checkThenElse ({exp1, ty1}, {exp2, ty2}, pos) = if ty1 = ty2 then () else ErrorMsg.error pos "Then Else disagree" (* not sure if this works *)
  												     
	fun transExp (exp) = 
		let fun trexp (A.NilExp) = {exp=(), ty=T.NIL}
			  | trexp (A.IntExp(ival)) = {exp=(), ty=T.INT}
			  | trexp (A.StringExp(sval)) = {exp=(), ty=T.STRING}
			  | trexp (A.VarExp(lvalue)) = {exp=(), ty = lookup(venv, lvalue, 69)} (* Do we need to check if lvalue is a function? *)
			  | trexp (A.WhileExp({test, body, pos})) = (checkInt(trexp test, pos); trexp body; {exp = (), ty = T.NIL}) 
			
			  | trexp (A.ForExp({var, escape, lo, hi, body, pos})) = (scopeDown(); venv:=S.enter(venv, var, T.INT); checkInt(lo); checkInt(hi); trexp body; scopeUp(); {exp = (), ty = T.NIL})
 			  | trexp (A.LetExp({decs, body, pos})) = (scopeDown; (*parseDecs;*) trexp body; scopeUp; {exp = (), ty = T.NIL}) 
			  | trexp (A.OpExp({left, oper, right, pos})) = (checkInt(trexp left, pos); checkInt(trexp right, pos); {exp=(), ty=T.INT})
			  | trexp (A.AssignExp({var, exp, pos})) = (venv := S.enter(venv, var, #ty(trexp exp)); {exp = (), ty=T.NIL}) 
			  | trexp (A.SeqExp({exps})) = {exp = (), ty = foldl (fn(x, y) => #ty(trexp #1(x))) T.NIL exps}
			  | trexp (A.CallExp({func, args, pos})) = (case lookup(venv, func, pos) of Env.FunEntry({formals, result}) => (checkArgs(formals, map (fn (x) => #ty(trexp x)) args, pos); {exp = (), ty = result})
											    | Env.VarEntry({ty})  => (ErrorMsg.Error pos "Variable is not function"; {exp = (), ty = T.NIL}))  
													  	      
			  | trexp (A.ArrayExp({typ, size, init, pos})) = (checkInt(trexp size, pos); if typ = #ty(trexp init) then () else ErrorMsg.Error pos "Initializing array with wrong type"; {exp = (), ty = T.NIL})
   			  | trexp (A.RecordExp({fields, typ, pos})) = (map (fn(x) => if lookup(lookup(tenv, typ, pos), (#1 x), pos) = #ty(trexp (#2 x)) then () else ErrorMsg.Error pos "Wrong initialization of type in record") fields;   {exp = (), ty = typ}) (* Checkme *)
			  | trexp (A.IfExp({test, then', else' = NONE, pos})) = (checkInt(trexp test, pos); {exp=(), ty= #ty(trexp then')})
			  | trexp (A.IfExp({test, then', else', pos})) = (checkInt(trexp test, pos); checkThenElse(trexp then', trexp else', pos); {exp = (), ty= #ty(trexp then')})
									      
					    
  		in 
			trexp exp
		end
	fun transProg(exp) = (transExp(exp); ()) 
				 
end
