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

    val stack: { tenv: tenvType, venv: venvType } list ref = ref []
    val tenv: (tenvType) ref = ref Env.base_tenv
    val venv: (venvType) ref = ref Env.base_venv
    fun checkArgs ([], [], pos) = ()
      | checkArgs (a::l1, [], pos) = E.error pos "Insufficient arguments"
      | checkArgs ([], b::l2, pos) = E.error pos "Too many arguments"
      | checkArgs (a::l1, b::l2, pos) = if a = b then checkArgs(l1, l2, pos) else E.error pos "Argument type mismatch"
    
    fun lookupType (t, v, pos) = (case S.look(t, v) of NONE => (E.error pos "Type undefined"; T.NIL)
                                                     | SOME x => x)
    fun checkInt ({exp, ty = T.INT}, pos) = ()
      | checkInt ({exp, ty}, pos) = E.error pos "Not int type"
    fun scopeDown () =
        stack := {tenv = !tenv, venv = !venv}::(!stack)
    fun scopeUp () =
        (fn(a::l) => (tenv := #tenv(a); venv := #venv(a); stack := l)) (!stack)
				     

    fun funcDecl (name, params, result, pos) =
	let val result_ty = (case result of NONE => T.NIL
					  | SOME(rt, pos) => lookupType(!tenv,rt,pos))
				
            fun transparam{name,escape,typ,pos} = {name=name,ty=lookupType(!tenv, typ, pos)}
                  
            val params' = map transparam params
            	       
            
        in venv := S.enter(!venv,name, Env.FunEntry{formals= map #ty params', result=result_ty}) 
	end
	    
   fun funcBody (name, params, result, pos) =
        let val result_ty = (case result of NONE => T.NIL
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
      			{exp = (), ty=(case #ty(transVar(venv, tenv, var)) of
      					T.RECORD(fields, u) => findField(fields, sym)
				      | x => (E.error pos "field var on non-record type"; T.NIL))}
				       
      		end
      | transVar (venv, tenv, A.SubscriptVar(var, exp, pos)) = 
      	let  val ty = (case #ty(transVar(venv, tenv, var)) of
      			   T.ARRAY(ty, u) => (checkInt(transExp(venv, tenv, exp), pos); ty) 
      			   | x => (E.error pos "subscript var on non-array type"; T.NIL))
	in
   		    {exp = (), ty = ty}
	end
	    
       
    and transDec (venv, tenv, A.VarDec({name, escape, typ=NONE, init, pos})) = 
            let 
                val {exp,ty} = transExp(venv,tenv,init) 
            in  
                {tenv=tenv,venv=(venv:=S.enter(!venv,name,Env.VarEntry{ty=ty});venv)}
            end
      | transDec (venv, tenv, A.VarDec({name, escape, typ=SOME(x), init, pos})) = 
            let 
                val {exp,ty} = transExp(venv,tenv,init) 
            in  
                if checkTypeEqual(lookupType(!tenv, #1 x, #2 x), ty) then 
                	{tenv=tenv, venv = (venv := S.enter(!venv,name,Env.VarEntry{ty=ty}); venv)}
                else (E.error pos "named type does not match expression";{tenv=tenv, venv=venv})
            end
      | transDec (venv,tenv,A.TypeDec[{name,ty,pos}]) = {venv=venv,tenv=(tenv:= S.enter(!tenv, name, T.NAME(name, ref NONE));
									 (case S.look(!tenv, name) of SOME(T.NAME(n, r)) => r := SOME(transTy(tenv, ty))); tenv)}
      | transDec (venv,tenv,A.TypeDec({name,ty,pos}::tydeclist)) = (tenv := S.enter(!tenv, name, T.NAME(name, ref NONE)); transDec(venv, tenv, A.TypeDec(tydeclist));
								    (case S.look(!tenv, name) of SOME(T.NAME(n, r)) => r := SOME(transTy(tenv, ty))); {venv=venv,tenv=tenv})
      | transDec (venv,tenv, A.FunctionDec[{name,params,body,pos,result}]) = (funcDecl(name, params, result, pos); checkTypeEqual(funcBody(name, params, result, pos), #ty(transExp(venv, tenv, body))); scopeUp; {venv = venv, tenv = tenv})
      | transDec (venv, tenv, A.FunctionDec({name,params,body,pos,result}::fundeclist)) = (funcDecl(name, params, result, pos); transDec(venv,tenv,A.FunctionDec(fundeclist)); checkTypeEqual(funcBody(name, params, result, pos), #ty(transExp(venv, tenv, body))); scopeUp; {venv = venv, tenv = tenv})								    
									      
 	

    

    and transTy(tenv, A.NameTy(sym, pos)) = 
        (case S.look(!tenv, sym) of
        	SOME(x) => T.NAME((print(" namesymbol:");print(S.name sym); sym), ref (SOME(x))) 
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
      	(case S.look(!tenv, (print(S.name sym);sym)) of
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
              | trexp (A.WhileExp({test, body, pos})) = (checkInt(trexp test, pos); if #ty(trexp body)=T.UNIT then () else E.error pos "while loop must be unit"; {exp = (), ty = T.NIL})
              | trexp (A.ForExp({var, escape, lo, hi, body, pos})) = (scopeDown; venv:=S.enter(!venv, var, Env.VarEntry{ty=T.INT}); checkInt(trexp lo, pos); checkInt(trexp hi, pos); if #ty(trexp body) = T.UNIT then () else E.error pos "for loop must be unit"; scopeUp(); {exp = (), ty = T.NIL})
              | trexp (A.LetExp({decs, body, pos})) = 
              let
              	val expty = (scopeDown; map (fn(x)=>(transDec(venv,tenv,x))) decs; trexp body)
              in
              	(scopeUp; expty)
              end
                                      
              | trexp (A.OpExp({left, oper, right, pos})) = (checkInt(trexp left, pos); checkInt(trexp right, pos); {exp=(), ty=T.INT})
              | trexp (A.AssignExp({var, exp, pos})) = (if #ty(trexp exp) = #ty(transVar(venv, tenv, var)) then () else E.error pos "Assigning wrong type to variable"; {exp = (), ty=T.NIL})  
              | trexp (A.SeqExp(exps)) = {exp = (), ty = foldl (fn(x, y) => #ty(trexp (#1 x))) T.NIL exps}
              | trexp (A.CallExp({func, args, pos})) = (case S.look(!venv, func) of SOME x =>
                                                (case x of  Env.FunEntry({formals, result}) => (checkArgs(formals, map (fn (x) => #ty(trexp x)) args, pos); {exp = (), ty = result})
                                                      | Env.VarEntry({ty})  => (E.error pos "Variable is not function"; {exp = (), ty = T.NIL}))
                                                                       
                                                  | NONE => (E.error pos "Variable undefined"; {exp = (), ty = T.NIL}))
                                                                                                                                                                                    
              | trexp (A.ArrayExp({typ, size, init, pos})) = (
              	checkInt(trexp size, pos); 
              	(case lookupType(!tenv, (print(S.name typ);typ), pos) of
              		T.ARRAY(ty, u) => if checkTypeEqual(ty,#ty(trexp init)) then () 
              				  else E.error pos "Initializing array with wrong type"
		      | T.NAME(n, r) => case !r of SOME(T.ARRAY(ty, u)) => if checkTypeEqual(ty,#ty(trexp init)) then ()
                                          else E.error pos "Initializing array with wrong type"
						 | x => (E.error pos "array type mismatch"));
		
              	{exp = (), ty = lookupType(!tenv, typ, pos)})
                (* | trexp (A.RecordExp({fields, typ, pos})) = (map (fn(x) => if findINdex(lookupType(!tenv, typ, pos), (#1 x), pos) = #ty(trexp (#2 x)) then () else E.Error pos "Wrong initialization of type in record") fields;   {exp = (), ty = typ}) *) (* Fixme *)
              | trexp (A.RecordExp({fields, typ, pos})) = 
              		(case lookupType(!tenv, typ, pos) of
                      T.RECORD(symlist, u) => if checkRecordType(fields, symlist) 
	                      then {exp=(), ty=T.RECORD(symlist, u)} 
	                      else (E.error pos "Wrong record type!"; {exp=(), ty=T.NIL})
			  | T.NAME(n, r) => case !r of SOME(T.RECORD(symlist, u)) => if checkRecordType(fields, symlist)
												       
										     then {exp=(), ty=T.RECORD(symlist, u)}
											      
										     else (E.error pos "Wrong record type!"; {exp=(), ty=T.NIL})
											      
 
                    | x => (E.error pos "Assigning record to not record type"; {exp=(), ty=T.NIL}))
              | trexp (A.IfExp({test, then', else', pos})) = (checkInt(trexp test, pos); (case else' of NONE => ()
                                                         | SOME x => if #ty(trexp then') = #ty(trexp x) then () else E.error pos "Then Else disagree");
                                      {exp=(), ty= #ty(trexp then')})              
                                          
                        
          in 
            trexp exp
        end
    fun transProg(exp) = (transExp(venv, tenv, exp); ()) 
                 
end
