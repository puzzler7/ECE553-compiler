exception CycleInTypeDec
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
    structure E = ErrorMsg
    type ty = Types.ty

    structure Translate = struct type exp = unit end
    type venvType = Env.enventry Symbol.table
    type tenvType = ty Symbol.table
    type expty = {exp: Translate.exp, ty: Types.ty}

    val loopdepth = ref 0
    val stack: { tenv: tenvType, venv: venvType } list ref = ref []
    val tenv: (tenvType) ref = ref Env.base_tenv
    val venv: (venvType) ref = ref Env.base_venv
    
    fun lookupType (t, v, pos) = (case S.look(t, v) of NONE => (E.error pos "Type undefined"; T.NIL)
                                                     | SOME x => x)
    fun checkInt ({exp, ty = T.INT}, pos) = ()
      | checkInt ({exp, ty}, pos) = E.error pos "Not int type"
    fun scopeDown () =
        stack := {tenv = !tenv, venv = !venv}::(!stack)
    fun scopeUp () =
        (fn(a::l) => (tenv := #tenv(a); venv := #venv(a); stack := l)) (!stack)
				     
    val seenFns:(S.symbol list) ref = ref []
    val seenTypes:(S.symbol list) ref = ref []

    fun checkIfSeen(x, []) = false
      | checkIfSeen(x, a::b) = a = x orelse checkIfSeen(x, b)

    fun funcDecl (name, params, result, pos) =
	let val result_ty = (case result of NONE => T.UNIT
					  | SOME(rt, pos) => lookupType(!tenv,rt,pos))
				
            fun transparam{name,escape,typ,pos} = {name=name,ty=lookupType(!tenv, typ, pos)}
                  
            val params' = map transparam params
            	       
            
        in (if checkIfSeen(name, (!seenFns)) then E.error pos "function declared twice in same fundec" else seenFns:= name :: !seenFns;
        	venv := S.enter(!venv,name, Env.FunEntry{formals= map #ty params', result=result_ty})) 
	end
	    
   fun funcBody (name, params, result, pos) =
        let val result_ty = (case result of NONE => T.UNIT
                                          | SOME(rt, pos) => lookupType(!tenv,rt,pos))

            fun transparam{name,escape,typ,pos} = {name=name,ty=lookupType(!tenv, typ, pos)}

            val params' = map transparam params


            fun enterparam ({name,ty},venv) =
                S.enter(venv,name,Env.VarEntry{ty=ty})
        in (scopeDown; venv := foldr enterparam (!venv) params'; result_ty)
        end


	    (* Use to check first element against the second, order matters i.e. assign type of second element to first *)
    fun checkTypeEqual(T.UNIT, T.UNIT) = true
      | checkTypeEqual(T.INT, T.INT) = true
      | checkTypeEqual(T.STRING, T.STRING) = true
      | checkTypeEqual(T.NIL, T.NIL) = true
      | checkTypeEqual(T.RECORD(symty1, u1), T.NIL)  = true
      | checkTypeEqual(T.ARRAY(ty1, u1), T.ARRAY(ty2, u2)) = u1=u2
      | checkTypeEqual(T.RECORD(symty1, u1), T.RECORD(symty2, u2)) = u1=u2
      | checkTypeEqual(T.NAME(sym, ty), x) = 
      	if T.NAME(sym, ty) = x then true else (case !ty of 
      						   NONE => false
      						 | SOME(y) => checkTypeEqual(y, x))
      | checkTypeEqual(x, y) = false   

    fun checkArgs ([], [], pos) = ()
      | checkArgs (a::l1, [], pos) = E.error pos "Insufficient arguments"
      | checkArgs ([], b::l2, pos) = E.error pos "Too many arguments"
      | checkArgs (a::l1, b::l2, pos) = if checkTypeEqual(a, b) then checkArgs(l1, l2, pos) else E.error pos "Argument type mismatch"

    fun existsCycle(T.NAME(sym, ty)) =	case !ty of NONE => false
						  | SOME(x) => checkTypeEqual(x, T.NAME(sym, ty))
									     
	      	
    fun getArrayFromName(T.ARRAY(ty, u)) = T.ARRAY(ty, u)    
      | getArrayFromName(T.NAME(sym, ty)) = (case !ty of 
      						   NONE => T.NIL
      						 | SOME(y) => getArrayFromName(y))
      | getArrayFromName(x) = T.NIL

    fun getRecordFromName(T.RECORD(l, u)) = T.RECORD(l, u)    
      | getRecordFromName(T.NAME(sym, ty)) = (case !ty of 
      						   NONE => T.NIL
      						 | SOME(y) => getRecordFromName(y))
      | getRecordFromName(x) = T.NIL
   
    fun checkComparisonOp(T.INT, T.INT) = true
      | checkComparisonOp(T.STRING, T.STRING) = true
      | checkComparisonOp(T.NIL, T.NIL) = false
      | checkComparisonOp(T.NIL, x) = true
      | checkComparisonOp(x, T.NIL) = true
      | checkComparisonOp(x, y) = false

    fun checkEqualityOp(T.INT, T.INT) = true
      | checkEqualityOp(T.RECORD(l1, u1), T.RECORD(l2, u2)) = true
      | checkEqualityOp(T.ARRAY(ty1, u1), T.ARRAY(ty2, u2)) = true
      | checkEqualityOp(T.STRING, T.STRING) = true
      | checkEqualityOp(T.NIL, T.NIL) = false
      | checkEqualityOp(T.NIL, x) = true
      | checkEqualityOp(x, T.NIL) = true
      | checkEqualityOp(x, y) = false

    fun checkRecordType ([], []) = true
      | checkRecordType ([], x) = false
      | checkRecordType (x, []) = false
      | checkRecordType ((asym, aexp, apos)::al, (bsym, bty)::bl) = asym=bsym andalso checkTypeEqual(bty, #ty(transExp(venv, tenv, aexp))) andalso checkRecordType(al, bl)

    (*and transVar (venv, tenv, var)=
        {exp = (), ty = (case S.look((!venv), symbolFromVar(var)) of
                 SOME x => (case x of
                        Env.VarEntry({ty}) => ty
                          | Env.FunEntry({formals, result}) => (E.error (posFromVar var) "Calling function as variable!"; result))
                   | NONE => (E.error (posFromVar var) "Variable does not exist!"; T.NIL))}*)

    and transVar (venv, tenv, A.SimpleVar(sym, pos)) = 
    	{exp = (), ty = (case S.look((!venv), sym) of
                 SOME x => (case x of
                        Env.VarEntry({ty}) => ty
                          | Env.FunEntry({formals, result}) => (E.error pos "Calling function as variable!"; result))
                   | NONE => (E.error pos "Variable does not exist!"; T.NIL))}
      | transVar (venv, tenv, A.FieldVar(var, sym, pos)) = 
      		let
      			fun findField([], sym) = T.NIL
      			  | findField((fsym, ty)::fields, sym) = if fsym = sym then ty else findField(fields, sym)
      		in
      			{exp = (), ty=(case getRecordFromName(#ty(transVar(venv, tenv, var))) of
      					T.RECORD(fields, u) => findField(fields, sym)
				      | x => (E.error pos "field var on non-record type"; T.NIL))}
				       
      		end
      | transVar (venv, tenv, A.SubscriptVar(var, exp, pos)) = 
      	let  val ty = (case getArrayFromName(#ty(transVar(venv, tenv, var))) of
      			   T.ARRAY(ty, u) => (checkInt(transExp(venv, tenv, exp), pos); ty) 
      			   | x => (E.error pos "subscript var on non-array type"; T.NIL))
	in
   		    {exp = (), ty = ty}
	end
	    
       
    and transDec (venv, tenv, A.VarDec({name, escape, typ=NONE, init, pos})) = 
            let 
                val {exp,ty} = transExp(venv,tenv,init) 
            in  
                (if checkTypeEqual(T.NIL, ty) then E.error pos "assigning nil to non-record" else();{tenv=tenv,venv=(venv:=S.enter(!venv,name,Env.VarEntry{ty=ty});venv)})
            end
      | transDec (venv, tenv, A.VarDec({name, escape, typ=SOME(x), init, pos})) = 
            let 
                val {exp,ty} = transExp(venv,tenv,init) 
            in  
                if checkTypeEqual(lookupType(!tenv, #1 x, #2 x), ty) then 
                	{tenv=tenv, venv = (venv := S.enter(!venv,name,Env.VarEntry{ty=lookupType(!tenv, #1 x, #2 x)}); venv)}
                else (E.error pos "named type does not match expression";{tenv=tenv, venv=venv})
            end
      | transDec (venv,tenv,A.TypeDec[{name,ty,pos}]) = {venv=venv,tenv=(tenv:= S.enter(!tenv, name, T.NAME(name, ref NONE));
					(case S.look(!tenv, name) of SOME(T.NAME(n, r)) => (r := SOME(transTy(tenv, ty)); if existsCycle(T.NAME(n,r)) then (raise CycleInTypeDec) else ())); if checkIfSeen(name, !seenTypes) then E.error pos "repeated type name in typedec" else ();seenTypes := [];tenv)}
      | transDec (venv,tenv,A.TypeDec({name,ty,pos}::tydeclist)) = (tenv := S.enter(!tenv, name, T.NAME(name, ref NONE)); transDec(venv, tenv, A.TypeDec(tydeclist));
								    (case S.look(!tenv, name) of SOME(T.NAME(n, r)) => (r := SOME(transTy(tenv, ty)); if existsCycle(T.NAME(n,r)) then (raise CycleInTypeDec) else ())); if checkIfSeen(name, !seenTypes) then E.error pos "repeated type name in typedec" else seenTypes:= name:: !seenTypes; {venv=venv,tenv=tenv})
      | transDec (venv,tenv, A.FunctionDec[{name,params,body,pos,result}]) = (funcDecl(name, params, result, pos); if checkTypeEqual(funcBody(name, params, result, pos), #ty(transExp(venv, tenv, body))) then () else E.error pos "function body and return type differ"; scopeUp;seenFns:= [];{venv = venv, tenv = tenv})
      | transDec (venv, tenv, A.FunctionDec({name,params,body,pos,result}::fundeclist)) = (funcDecl(name, params, result, pos);transDec(venv,tenv,A.FunctionDec(fundeclist)); if checkTypeEqual(funcBody(name, params, result, pos), #ty(transExp(venv, tenv, body))) then () else E.error pos "function body and return type differ"; scopeUp; {venv = venv, tenv = tenv})								    
									      
 	

    

    and transTy(tenv, A.NameTy(sym, pos)) = 
        (case S.look(!tenv, sym) of
        	SOME(x) => T.NAME(sym, ref (SOME(x))) 
            | NONE => (E.error pos "type does not exist";T.NIL))
            (*SOME(T.NAME(sym, ty)) => T.NAME(sym, ty)
            | SOME(x) => (E.error pos "could not find name type"; T.NIL)
            | NONE => (E.error pos "type does not exist";T.NIL))*)
      | transTy(tenv, A.RecordTy(fields)) = 
      		let
      			fun makeSymtyList ([]) = []
      			  | makeSymtyList ({name, escape, typ, pos}::fields) = (name, lookupType(!tenv, typ, pos))::makeSymtyList(fields)
      		in
      			T.RECORD(makeSymtyList(fields), ref ())
      		end
      | transTy(tenv, A.ArrayTy(sym, pos)) = 
      	(case S.look(!tenv, sym) of
            SOME(x) => T.ARRAY(x, ref ())
            | NONE => (E.error pos "type does not exist";T.NIL))
            (*SOME(T.ARRAY(ty, ref ())) => T.ARRAY(ty, ref ())
            | SOME(x) => (E.error pos "could not find array type"; T.NIL)
            | NONE => (E.error pos "type does not exist";T.NIL))*)

    and transExp (venv, tenv, exp) = 
        let fun trexp (A.NilExp) = {exp=(), ty=T.NIL}
              | trexp (A.IntExp(ival)) = {exp=(), ty=T.INT}
              | trexp (A.StringExp(sval)) = {exp=(), ty=T.STRING}
              | trexp (A.VarExp(lvalue)) = transVar(venv, tenv, lvalue)
              | trexp (A.WhileExp({test, body, pos})) = (checkInt(trexp test, pos); if #ty(trexp body)=T.UNIT then (scopeDown; loopdepth:= !loopdepth+1;()) else E.error pos "while loop must be unit"; {exp = (), ty = T.UNIT})
              | trexp (A.ForExp({var, escape, lo, hi, body, pos})) = 
              	(scopeDown;
              	 venv:=S.enter(!venv, var, Env.VarEntry{ty=T.INT});
              	 checkInt(trexp lo, pos); checkInt(trexp hi, pos);
              	  (if #ty(trexp body) = T.UNIT 
              	  then (loopdepth:= !loopdepth+1;()) 
              	  else (E.error pos "for loop must be unit";()));
              	  {exp = (), ty = T.UNIT})
              | trexp (A.LetExp({decs, body, pos})) = 
              let
              	val expty = (scopeDown; map (fn(x)=>(transDec(venv,tenv,x))) decs; trexp body)
              in
              	(scopeUp; (*if checkTypeEqual(#ty expty, T.UNIT) then () else E.error pos "let returns non unit";*)expty)
              end
                                      
              | trexp (A.OpExp({left, oper, right, pos})) = 
              		(case oper of 
              			A.PlusOp => (checkInt(trexp left, pos); checkInt(trexp right, pos); {exp=(), ty=T.INT})
              		  | A.MinusOp =>(checkInt(trexp left, pos); checkInt(trexp right, pos); {exp=(), ty=T.INT})
              		  | A.DivideOp =>(checkInt(trexp left, pos); checkInt(trexp right, pos); {exp=(), ty=T.INT})
              		  | A.TimesOp =>(checkInt(trexp left, pos); checkInt(trexp right, pos); {exp=(), ty=T.INT})
              		  | A.EqOp => if checkEqualityOp(#ty(trexp left), #ty(trexp right)) then {exp=(), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=(), ty=T.INT})
              		  | A.NeqOp => if checkEqualityOp(#ty(trexp left), #ty(trexp right)) then {exp=(), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=(), ty=T.INT})
              		  | A.GtOp => if checkComparisonOp(#ty(trexp left), #ty(trexp right)) then {exp=(), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=(), ty=T.INT})
              		  | A.LtOp => if checkComparisonOp(#ty(trexp left), #ty(trexp right)) then {exp=(), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=(), ty=T.INT})
              		  | A.GeOp => if checkComparisonOp(#ty(trexp left), #ty(trexp right)) then {exp=(), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=(), ty=T.INT})
              		  | A.LeOp => if checkComparisonOp(#ty(trexp left), #ty(trexp right)) then {exp=(), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=(), ty=T.INT}))

              | trexp (A.AssignExp({var, exp, pos})) = (if checkTypeEqual(#ty(transVar(venv, tenv, var)), #ty(trexp exp)) then () else E.error pos "Assigning wrong type to variable"; {exp = (), ty=T.UNIT})  
              | trexp (A.SeqExp(exps)) = {exp = (), ty = foldl (fn(x, y) => #ty(trexp (#1 x))) T.UNIT exps}
              | trexp (A.CallExp({func, args, pos})) = (case S.look(!venv, func) of SOME x =>
                                                (case x of  Env.FunEntry({formals, result}) => (checkArgs(formals, map (fn (x) => #ty(trexp x)) args, pos); {exp = (), ty = result})
                                                      | Env.VarEntry({ty})  => (E.error pos "Variable is not function"; {exp = (), ty = T.NIL}))
                                                                       
                                                  | NONE => (E.error pos "Variable undefined"; {exp = (), ty = T.NIL}))
                                                                                                                                                                                    
              | trexp (A.ArrayExp({typ, size, init, pos})) = (
              	checkInt(trexp size, pos); 
              	(case getArrayFromName(lookupType(!tenv, typ, pos)) of
              		T.ARRAY(ty, u) => if checkTypeEqual(ty,#ty(trexp init)) then () 
              				  else E.error pos "Initializing array with wrong type"
				  | x => (E.error pos "array type mismatch"));
		
              	{exp = (), ty = lookupType(!tenv, typ, pos)})

              | trexp (A.RecordExp({fields, typ, pos})) = 
              		(case getRecordFromName(lookupType(!tenv, typ, pos)) of
                      T.RECORD(symlist, u) => if checkRecordType(fields, symlist) 
	                      then {exp=(), ty=T.RECORD(symlist, u)} 
	                      else (E.error pos "Wrong record type!"; {exp=(), ty=T.NIL})
                    | x => (E.error pos "Assigning record to not record type"; {exp=(), ty=T.NIL}))
              | trexp (A.IfExp({test, then', else', pos})) = (checkInt(trexp test, pos); 
              	(case else' of 
              		NONE => if checkTypeEqual(#ty(trexp then'), T.UNIT) then () else E.error pos "If returns non-unit"
                  | SOME x => if (checkTypeEqual(#ty(trexp then'), #ty(trexp x)) orelse checkTypeEqual(#ty(trexp x), #ty(trexp then'))) then () else E.error pos "Then Else disagree");
                  {exp=(), ty= #ty(trexp then')})     
              | trexp (A.BreakExp(pos)) = if !loopdepth > 0 
              		then (scopeUp; loopdepth:= !loopdepth-1;{exp=(),ty=T.NIL})
              		else (E.error pos "break not in loop!"; {exp=(), ty=T.NIL})      
                                          
                        
          in 
            trexp exp
        end
    fun transProg(exp) = (transExp(venv, tenv, exp); ()) 
                 
end
