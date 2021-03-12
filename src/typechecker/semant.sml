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
    fun symbolFromVar (A.SimpleVar(s, pos)) = s                              
      | symbolFromVar (A.FieldVar(v, s, pos)) = s
      | symbolFromVar (A.SubscriptVar(v, e, pos)) = symbolFromVar(v)
      
    fun posFromVar (A.SimpleVar(s, pos)) = pos
      | posFromVar (A.FieldVar(v, s, pos)) = pos
      | posFromVar (A.SubscriptVar(v, e, pos)) = pos        
       fun checkInt ({exp, ty = T.INT}, pos) = ()
      | checkInt ({exp, ty}, pos) = E.error pos "Not int type"
    fun scopeDown () =
        stack := {tenv = !tenv, venv = !venv}::(!stack)
    fun scopeUp () =
        (fn(a::l) => (tenv := #tenv(a); venv := #venv(a); stack := l)) (!stack)

    fun checkRecordType ([], []) = true
      | checkRecordType ([], x) = false
      | checkRecordType (x, []) = false
      | checkRecordType ((asym, aexp, apos)::al, (bsym, bty)::bl) = asym=bsym andalso #ty(transExp(aexp))=bty andalso checkRecordType(al, bl)

    (*and transVar (venv, tenv, var)=
        {exp = (), ty = (case S.look((!venv), symbolFromVar(var)) of
                 SOME x => (case x of
                        Env.VarEntry({ty}) => ty
                          | Env.FunEntry({formals, result}) => (E.error (posFromVar var) "Calling function as variable!"; result))
                   | NONE => (E.error (posFromVar var) "Variable does not exist!"; T.NIL))}*)

    and transVar (venv, tenv, SimpleVar(sym, pos)) = 
    	{exp = (), ty = (case S.look((!venv), sym) of
                 SOME x => (case x of
                        Env.VarEntry({ty}) => ty
                          | Env.FunEntry({formals, result}) => (E.error pos "Calling function as variable!"; result))
                   | NONE => (E.error pos "Variable does not exist!"; T.NIL))}
      | transVar (venv, tenv, FieldVar(var, sym, pos)) = 
      		let
      			fun findField([], sym) = T.NIL
      			  | findField((fsym, ty)::fields, sym) = if fsym = sym then ty else findField(fields, sym)
      		in
      			case transVar(var) of
      				T.RECORD(fields, u) => findField(fields, sym)
      				| x => (E.error pos "field var on non-record type"; T.NIL)
      		end
      | transVar (venv, tenv, SubscriptVar(var, exp, pos)) = 
      		(case transVar(var) of
      			T.ARRAY(ty, u) => if checkInt(transExp(exp)) then ty else T.NIL
      			| x => (E.error pos "subscript var on non-array type"; T.NIL) )
       
    and transDec(venv, tenv, A.VarDec(name, escape, typ=NONE, init, pos)) = 
            let 
                val {exp,ty} = transExp(venv,tenv,init) 
            in  
                {tenv=tenv,venv=S.enter(venv,name,Env.VarEntry{ty=ty})}
            end
      | transDec(venv, tenv, A.VarDec(name, escape, typ, init, pos)) = 
            let 
                val {exp,ty} = transExp(venv,tenv,init) 
            in  
                if ty=typ then {tenv=tenv,venv=S.enter(venv,name,Env.VarEntry{ty=ty})}
                else (E.error pos "named type does not match expression";{tenv=tenv, venv=venv})
            end
      | transDec(venv,tenv,A.TypeDec[{name,ty}]) = {venv=venv,tenv=S.enter(tenv,name,transTy(tenv,ty))}
      | transDec(venv,tenv,A.TypeDec({name,ty}::tydeclist)) = (transDec(venv, tenv, tydeclist);{venv=venv,tenv=S.enter(tenv,name,transTy(tenv,ty))})

    and transTy(tenv, A.NameTy(sym, pos)) = 
        (case S.look(tenv, sym) of
            SOME(T.NAME(sym, ty)) => T.NAME(sym, ty)
            | SOME(x) => (E.error pos "could not find name type"; T.NIL)
            | NONE => (E.error pos "type does not exist";T.NIL))
      | transTy(tenv, A.RecordTy(fields)) = 
      		let
      			fun makeSymtyList ([]) = []
      			  | makeSymtyList ({name, escape, typ, pos}::fields) = (name, typ)::makeSymtyList(fields)
      		in
      			T.RECORD(makeSymtyList(fields), ref ())
      		end
      | transTy(tenv, A.ArrayTy(sym, pos)) = 
      	(case S.look(tenv, sym) of
            SOME(T.Array(ty, u)) => T.Array(ty, u)
            | SOME(x) => (E.error pos "could not find array type"; T.NIL)
            | NONE => (E.error pos "type does not exist";T.NIL))

    and transExp (exp) = 
        let fun trexp (A.NilExp) = {exp=(), ty=T.NIL}
              | trexp (A.IntExp(ival)) = {exp=(), ty=T.INT}
              | trexp (A.StringExp(sval)) = {exp=(), ty=T.STRING}
              | trexp (A.VarExp(lvalue)) = transVar(venv, tenv, lvalue)
              | trexp (A.WhileExp({test, body, pos})) = (checkInt(trexp test, pos); trexp body; {exp = (), ty = T.NIL})
              | trexp (A.ForExp({var, escape, lo, hi, body, pos})) = (scopeDown(); venv:=S.enter(!venv, var, Env.VarEntry{ty=T.INT}); checkInt(trexp lo, pos); checkInt(trexp hi, pos); trexp body; scopeUp(); {exp = (), ty = T.NIL})
              | trexp (A.LetExp({decs, body, pos})) = (scopeDown; (*parseDecs;*) trexp body; scopeUp; {exp = (), ty = T.NIL})
                                      
              | trexp (A.OpExp({left, oper, right, pos})) = (checkInt(trexp left, pos); checkInt(trexp right, pos); {exp=(), ty=T.INT})
              | trexp (A.AssignExp({var, exp, pos})) = (if #ty(trexp exp) = #ty(transVar(venv, tenv, var)) then () else E.error pos "Assigning wrong type to variable"; {exp = (), ty=T.NIL})  
              | trexp (A.SeqExp(exps)) = {exp = (), ty = foldl (fn(x, y) => #ty(trexp (#1 x))) T.NIL exps}
              | trexp (A.CallExp({func, args, pos})) = (case S.look(!venv, func) of SOME x =>
                                                (case x of  Env.FunEntry({formals, result}) => (checkArgs(formals, map (fn (x) => #ty(trexp x)) args, pos); {exp = (), ty = result})
                                                      | Env.VarEntry({ty})  => (E.error pos "Variable is not function"; {exp = (), ty = T.NIL}))
                                                                       
                                                  | NONE => (E.error pos "Variable undefined"; {exp = (), ty = T.NIL}))
                                                                                                                                                                                    
              | trexp (A.ArrayExp({typ, size, init, pos})) = (checkInt(trexp size, pos); if lookupType(!tenv, typ, pos) = #ty(trexp init) then () else E.error pos "Initializing array with wrong type"; {exp = (), ty = T.ARRAY(lookupType(!tenv, typ, pos), ref ())})
                (* | trexp (A.RecordExp({fields, typ, pos})) = (map (fn(x) => if findINdex(lookupType(!tenv, typ, pos), (#1 x), pos) = #ty(trexp (#2 x)) then () else E.Error pos "Wrong initialization of type in record") fields;   {exp = (), ty = typ}) *) (* Fixme *)
              | trexp (A.RecordExp({fields, typ, pos})) = (case lookupType(!tenv, typ, pos) of
                      T.RECORD(symlist, u) => if checkRecordType(fields, symlist) then {exp=(), ty=T.RECORD(symlist, u)} else (E.error pos "Wrong record type!"; {exp=(), ty=T.NIL})
                    | x => (E.error pos "Assigning record to not record type"; {exp=(), ty=T.NIL}))
              | trexp (A.IfExp({test, then', else', pos})) = (checkInt(trexp test, pos); (case else' of NONE => ()
                                                         | SOME x => if #ty(trexp then') = #ty(trexp x) then () else E.error pos "Then Else disagree");
                                      {exp=(), ty= #ty(trexp then')})              
                                          
                        
          in 
            trexp exp
        end
    fun transProg(exp) = (transExp(exp); ()) 
                 
end
