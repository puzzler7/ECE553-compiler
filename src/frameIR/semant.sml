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
    structure Find = FindEscape
    type ty = Types.ty

    structure TR = Translate
    type venvType = Env.enventry Symbol.table
    type tenvType = ty Symbol.table
    type expty = {exp: TR.exp, ty: Types.ty}

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

    fun funcDecl (name, params, result, level, pos) =
	let val result_ty = (case result of NONE => T.UNIT
					  | SOME(rt, pos) => lookupType(!tenv,rt,pos))
				
            fun transparam{name,escape,typ,pos} = {name=name,ty=lookupType(!tenv, typ, pos)}
                  
            val params' = map transparam params
            	       
            
        in (if checkIfSeen(name, (!seenFns)) then E.error pos "function declared twice in same fundec" else seenFns:= name :: !seenFns;
        	venv := S.enter(!venv,name, Env.FunEntry{level=level, formals= map #ty params', result=result_ty})) (*FIXME new level?*)
	end
	    
   fun funcBody (name, params: A.field list, result, pos, level) =
        let val result_ty = (case result of NONE => T.UNIT
                                          | SOME(rt, pos) => lookupType(!tenv,rt,pos))

            fun transparam{name,escape,typ,pos} = {name=name,escape=escape,ty=lookupType(!tenv, typ, pos)}

            val params' = map transparam params


            fun enterparam ({name,escape,ty},venv) =
                S.enter(venv,name,Env.VarEntry{access=TR.allocLocal(level)(!escape), ty=ty})
        in (scopeDown; venv := foldr enterparam (!venv) params'; result_ty)
        end


   fun leftrec(T.NAME(sym, ty), x) = if T.NAME(sym, ty) = x then true else (case !ty of
																		       
										NONE => false
									      | SOME(T.NAME(symb, typ)) => leftrec(T.NAME(symb, typ), x)
									      | SOME(q) => checkTypeEqual(q, x))
     | leftrec (y,x) = false
      
   and rightrec(x, T.NAME(sym, ty)) = if T.NAME(sym, ty) = x then true else (case !ty of
										 NONE => false
									       | SOME(y) => rightrec(x, y))
     | rightrec (x, y) = false
			     
      
      
								     
	    (* Use to check first element against the second, order matters i.e. assign type of second element to first *)
    and checkTypeEqual(T.UNIT, T.UNIT) = true
      | checkTypeEqual(T.INT, T.INT) = true
      | checkTypeEqual(T.STRING, T.STRING) = true
      | checkTypeEqual(T.NIL, T.NIL) = true
      | checkTypeEqual(T.RECORD(symty1, u1), T.NIL)  = true
      | checkTypeEqual(T.ARRAY(ty1, u1), T.ARRAY(ty2, u2)) = u1=u2
      | checkTypeEqual(T.RECORD(symty1, u1), T.RECORD(symty2, u2)) = u1=u2
      | checkTypeEqual(T.NAME(sym1, ty1), T.NAME(sym2, ty2)) = rightrec(T.NAME(sym1, ty1), T.NAME(sym2, ty2)) orelse rightrec(T.NAME(sym1, ty1), T.NAME(sym2, ty2))
      | checkTypeEqual (T.NAME(sym, ty), x) = leftrec(T.NAME(sym, ty),x) 
      | checkTypeEqual (x, y) = false 
				   

    fun checkArgs ([], [], pos) = ()
      | checkArgs (a::l1, [], pos) = E.error pos "Insufficient arguments"
      | checkArgs ([], b::l2, pos) = E.error pos "Too many arguments"
      | checkArgs (a::l1, b::l2, pos) = if checkTypeEqual(a, b) then checkArgs(l1, l2, pos) else E.error pos "Argument type mismatch"

    fun existsCycle(T.NAME(sym, ty)) =	case !ty of NONE => false
						  | SOME(x) => leftrec(x, T.NAME(sym, ty))
									     
	      	
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

    fun forToWhile(A.ForExp({var, escape, lo, hi, body, pos})) = 
        let val limit = S.symbol "__limit"
        in
          A.LetExp({decs=[A.VarDec{name=var, escape=ref false, typ=SOME((S.symbol "int", pos)), init=lo, pos=pos},
              A.VarDec{name=limit, escape=ref false, typ=SOME((S.symbol "int", pos)), init=hi, pos=pos}],
            body=A.WhileExp{test=A.OpExp{left=A.VarExp(A.SimpleVar(var, pos)),
                oper=A.LeOp,
                right=A.VarExp(A.SimpleVar(limit, pos)),
                pos=pos},
              body=A.SeqExp[(body, pos), (*body, if i==limit then break, increment*)
                  (A.IfExp{test=A.OpExp{left=A.VarExp(A.SimpleVar(var, pos)),
                            oper=A.LtOp,
                            right=A.VarExp(A.SimpleVar(limit, pos)),
                            pos=pos},
                        then'=A.BreakExp(pos),
                        else'=NONE,
                        pos=pos}, pos),
                  (A.AssignExp{var=A.SimpleVar(var, pos),
                      exp=A.OpExp{left=A.VarExp(A.SimpleVar(var, pos)),
                          oper=A.PlusOp,
                          right=A.IntExp(1),
                          pos=pos},
                      pos=pos}, pos)],
              pos=pos},
            pos=pos})
        end

    fun checkRecordType ([], [], _, _) = true
      | checkRecordType ([], x, _, _) = false
      | checkRecordType (x, [], _, _) = false
      | checkRecordType ((asym, aexp, apos)::al, (bsym, bty)::bl, break, level) = asym=bsym andalso checkTypeEqual(bty, #ty(transExp(venv, tenv, aexp, break, level))) andalso checkRecordType(al, bl, break, level)

    (*and transVar (venv, tenv, var)=
        {exp = (), ty = (case S.look((!venv), symbolFromVar(var)) of
                 SOME x => (case x of
                        Env.VarEntry({ty}) => ty
                          | Env.FunEntry({formals, result}) => (E.error (posFromVar var) "Calling function as variable!"; result))
                   | NONE => (E.error (posFromVar var) "Variable does not exist!"; T.NIL))}*)

    and transVar (venv, tenv, A.SimpleVar(sym, pos), break, level) = 
        let
          val ty = (case S.look((!venv), sym) of
                 SOME x => (case x of
                        Env.VarEntry({access, ty}) => ty
                          | Env.FunEntry({level, formals, result}) => (E.error pos "Calling function as variable!"; result))
                   | NONE => (E.error pos "Variable does not exist!"; T.NIL))
          val exp = (case S.look((!venv), sym) of
                 SOME x => (case x of
                        Env.VarEntry({access, ty}) => TR.simpleVar(access)
                          | Env.FunEntry({level, formals, result}) => (E.error pos "Calling function as variable!"; TR.NIL))
                   | NONE => (E.error pos "Variable does not exist!"; TR.NIL))
        in
          {exp=exp, ty=ty}
        end
      | transVar (venv, tenv, A.FieldVar(var, sym, pos), break, level) = 
      		let
      			fun findField([], sym) = T.NIL
      			  | findField((fsym, ty)::fields, sym) = if fsym = sym then ty else findField(fields, sym)
      		in
      			{exp = TR.FIXME, ty=(case getRecordFromName(#ty(transVar(venv, tenv, var, break, level))) of
      					T.RECORD(fields, u) => findField(fields, sym)
				      | x => (E.error pos "field var on non-record type"; T.NIL))}
				       
      		end
      | transVar (venv, tenv, A.SubscriptVar(var, exp, pos), break, level) = 
      	let  val ty = (case getArrayFromName(#ty(transVar(venv, tenv, var, break, level))) of
      			   T.ARRAY(ty, u) => (checkInt(transExp(venv, tenv, exp, break, level), pos); ty) 
      			   | x => (E.error pos "subscript var on non-array type"; T.NIL))
	in
   		    {exp = TR.FIXME, ty = ty}
	end
	    
       
    and transDec(venv, tenv, dec, break, level) = 
    	let
	    	fun trdec (venv, tenv, A.VarDec({name, escape, typ=NONE, init, pos})) = 
	            let 
	                val {exp,ty} = transExp(venv,tenv,init, break, level) 
	            in  
	                (if checkTypeEqual(T.NIL, ty) then E.error pos "assigning nil to non-record" else();{tenv=tenv,venv=(venv:=S.enter(!venv,name,Env.VarEntry{access=TR.allocLocal(level)(!escape),ty=ty});venv)})
	            end
	      | trdec (venv, tenv, A.VarDec({name, escape, typ=SOME(x), init, pos})) = 
	            let 
	                val {exp,ty} = transExp(venv,tenv,init, break, level) 
	            in  
	                if checkTypeEqual(lookupType(!tenv, #1 x, #2 x), ty) then 
	                	{tenv=tenv, venv = (venv := S.enter(!venv,name,Env.VarEntry{access=TR.allocLocal(level)(!escape),ty=lookupType(!tenv, #1 x, #2 x)}); venv)}
	                else (E.error pos "named type does not match expression";{tenv=tenv, venv=venv})
	            end
	      | trdec (venv,tenv,A.TypeDec[{name,ty,pos}]) = {venv=venv,tenv=(tenv:= S.enter(!tenv, name, T.NAME(name, ref NONE));
						(case S.look(!tenv, name) of SOME(T.NAME(n, r)) => (r := SOME(transTy(tenv, ty)); if existsCycle(T.NAME(n,r)) then (raise CycleInTypeDec) else ())); if checkIfSeen(name, !seenTypes) then E.error pos "repeated type name in typedec" else seenTypes:= name:: !seenTypes;tenv)}
	      | trdec (venv,tenv,A.TypeDec({name,ty,pos}::tydeclist)) = (tenv := S.enter(!tenv, name, T.NAME(name, ref NONE)); trdec(venv, tenv, A.TypeDec(tydeclist));
									    (case S.look(!tenv, name) of SOME(T.NAME(n, r)) => (r := SOME(transTy(tenv, ty)); if existsCycle(T.NAME(n,r)) then (raise CycleInTypeDec) else ())); if checkIfSeen(name, !seenTypes) then E.error pos "repeated type name in typedec" else seenTypes:= name:: !seenTypes;{venv=venv,tenv=tenv})
	      | trdec (venv,tenv, A.FunctionDec[{name,params,body,pos,result}]) = (funcDecl(name, params, result, level, pos); if checkTypeEqual(funcBody(name, params, result, pos, level), #ty(transExp(venv, tenv, body, break, level))) then () else E.error pos "function body and return type differ"; scopeUp;{venv = venv, tenv = tenv})
	      | trdec (venv, tenv, A.FunctionDec({name,params,body,pos,result}::fundeclist)) = (funcDecl(name, params, result, level, pos);trdec(venv, tenv, A.FunctionDec(fundeclist)); if checkTypeEqual(funcBody(name, params, result, pos, level), #ty(transExp(venv, tenv, body, break, level))) then () else E.error pos "function body and return type differ"; scopeUp; {venv = venv, tenv = tenv})				
	    in
	    	(seenFns := []; seenTypes:= []; trdec(venv, tenv, dec))
	    end				    
									      
 	

    

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

    and transExp (venv, tenv, exp, break, level) = 
        let fun trexp (A.NilExp, break) = {exp=TR.nilIR(), ty=T.NIL}
              | trexp (A.IntExp(ival), break) = {exp=TR.intIR(ival), ty=T.INT}
              | trexp (A.StringExp(sval), break) = {exp=TR.FIXME, ty=T.STRING}
              | trexp (A.VarExp(lvalue), break) = transVar(venv, tenv, lvalue, break, level)
              | trexp (A.WhileExp({test, body, pos}), break) = (checkInt(trexp (test, break), pos); if #ty(trexp (body, break))=T.UNIT then (scopeDown; loopdepth:= !loopdepth+1;()) else (E.error pos "while loop must be unit"); 
                let val newbreak = Temp.newlabel() in {exp = TR.whileIR(#exp (trexp (test, break)), #exp (trexp (body, break)), newbreak), ty = T.UNIT} end)
              | trexp (A.ForExp({var, escape, lo, hi, body, pos}), break) = 
              	(scopeDown; (*Remove this scopedown now that we're turning it into a let/while?*)
              	 venv:=S.enter(!venv, var, Env.VarEntry{access=TR.allocLocal(level)(!escape),ty=T.INT});
              	 checkInt(trexp (lo, break), pos);
                 checkInt(trexp (hi, break), pos);
              	  (if #ty(trexp (body, break)) = T.UNIT 
              	  then (loopdepth:= !loopdepth+1;()) 
              	  else (E.error pos "for loop must be unit";()));
              	  let 
                    val x = A.ForExp({var=var, escape=escape, lo=lo, hi=hi, body=body, pos=pos})
                    val fwhile = forToWhile(x) 
                  in trexp (fwhile, break) 
                  end)
              | trexp (A.LetExp({decs, body, pos}), break) = 
              let
              	val expty = (scopeDown; map (fn(x)=>(transDec(venv,tenv,x, break, level))) decs; trexp (body, break))
              in
              	(scopeUp; (*if checkTypeEqual(#ty expty, T.UNIT) then () else E.error pos "let returns non unit";*)expty)
              end
                                      
              | trexp (A.OpExp({left, oper, right, pos}), break) = 
              		(case oper of 
              			A.PlusOp => (checkInt(trexp (left, break), pos); checkInt(trexp (right, break), pos); {exp=TR.binopIR(oper, #exp (trexp (left, break)), #exp (trexp (right, break))), ty=T.INT})
              		  | A.MinusOp =>(checkInt(trexp (left, break), pos); checkInt(trexp (right, break), pos); {exp=TR.binopIR(oper, #exp (trexp (left, break)), #exp (trexp (right, break))), ty=T.INT})
              		  | A.DivideOp =>(checkInt(trexp (left, break), pos); checkInt(trexp (right, break), pos); {exp=TR.binopIR(oper, #exp (trexp (left, break)), #exp (trexp (right, break))), ty=T.INT})
              		  | A.TimesOp =>(checkInt(trexp (left, break), pos); checkInt(trexp (right, break), pos); {exp=TR.binopIR(oper, #exp (trexp (left, break)), #exp (trexp (right, break))), ty=T.INT})
              		  | A.EqOp => if checkEqualityOp(#ty(trexp (left, break)), #ty(trexp (right, break))) then {exp=TR.relopIR(oper, #exp (trexp (left, break)), #exp (trexp (right, break)), #ty (trexp (right, break))), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=TR.nilIR(), ty=T.INT})
              		  | A.NeqOp => if checkEqualityOp(#ty(trexp (left, break)), #ty(trexp (right, break))) then {exp=TR.relopIR(oper, #exp (trexp (left, break)), #exp (trexp (right, break)), #ty (trexp (right, break))), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=TR.nilIR(), ty=T.INT})
              		  | A.GtOp => if checkComparisonOp(#ty(trexp (left, break)), #ty(trexp (right, break))) then {exp=TR.relopIR(oper, #exp (trexp (left, break)), #exp (trexp (right, break)), #ty (trexp (right, break))), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=TR.nilIR(), ty=T.INT})
              		  | A.LtOp => if checkComparisonOp(#ty(trexp (left, break)), #ty(trexp (right, break))) then {exp=TR.relopIR(oper, #exp (trexp (left, break)), #exp (trexp (right, break)), #ty (trexp (right, break))), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=TR.nilIR(), ty=T.INT})
              		  | A.GeOp => if checkComparisonOp(#ty(trexp (left, break)), #ty(trexp (right, break))) then {exp=TR.relopIR(oper, #exp (trexp (left, break)), #exp (trexp (right, break)), #ty (trexp (right, break))), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=TR.nilIR(), ty=T.INT})
              		  | A.LeOp => if checkComparisonOp(#ty(trexp (left, break)), #ty(trexp (right, break))) then {exp=TR.relopIR(oper, #exp (trexp (left, break)), #exp (trexp (right, break)), #ty (trexp (right, break))), ty=T.INT} else (E.error pos "Bad types for comparison operator"; {exp=TR.nilIR(), ty=T.INT}))

              | trexp (A.AssignExp({var, exp, pos}), break) = (if checkTypeEqual(#ty(transVar(venv, tenv, var,break, level)), #ty(trexp (exp, break))) then () else E.error pos "Assigning wrong type to variable"; {exp = TR.assignIR(#exp (transVar(venv, tenv,var, break, level)), #exp(trexp(exp, break))), ty=T.UNIT})  
              | trexp (A.SeqExp(exps), break) = foldl (fn(x, y) => (trexp ((#1 x), break))) {exp=TR.Ex(Tree.CONST 0), ty=T.UNIT} exps
              | trexp (A.CallExp({func, args, pos}), break) = (case S.look(!venv, func) of SOME x =>
                                                (case x of  Env.FunEntry({level=level, formals=formals, result=result}) => (checkArgs(formals, map (fn (x) => #ty(trexp (x, break))) args, pos); {exp = TR.FIXME, ty = result})
                                                      | Env.VarEntry({access, ty})  => (E.error pos "Variable is not function"; {exp = TR.nilIR(), ty = T.NIL}))
                                                                       
                                                  | NONE => (E.error pos "Variable undefined"; {exp = TR.nilIR(), ty = T.NIL}))
                                                                                                                                                                                    
              | trexp (A.ArrayExp({typ, size, init, pos}), break) = (
              	checkInt(trexp (size, break), pos); 
              	(case getArrayFromName(lookupType(!tenv, typ, pos)) of
              		T.ARRAY(ty, u) => if checkTypeEqual(ty,#ty(trexp (init, break))) then () 
              				  else E.error pos "Initializing array with wrong type"
				  | x => (E.error pos "array type mismatch"));
		
              	{exp = TR.arrayVar(#exp (trexp(size, break)), #exp (trexp(init, break))), ty = lookupType(!tenv, typ, pos)})

              | trexp (A.RecordExp({fields, typ, pos}), break) = 
              		(case getRecordFromName(lookupType(!tenv, typ, pos)) of
                      T.RECORD(symlist, u) => if checkRecordType(fields, symlist, break, level) 
	                      then {exp=TR.FIXME, ty=T.RECORD(symlist, u)} 
	                      else (E.error pos "Wrong record type!"; {exp=TR.nilIR(), ty=T.NIL})
                    | x => (E.error pos "Assigning record to not record type"; {exp=TR.nilIR(), ty=T.NIL}))
              | trexp (A.IfExp({test, then', else', pos}), break) = (checkInt(trexp (test, break), pos); 
              	(case else' of 
              		NONE => if checkTypeEqual(#ty(trexp (then', break)), T.UNIT) then () else E.error pos "If returns non-unit"
                  | SOME x => if (checkTypeEqual(#ty(trexp (then', break)), #ty(trexp (x, break))) orelse checkTypeEqual(#ty(trexp (x, break)), #ty(trexp (then', break)))) then () else E.error pos "Then Else disagree");
                  {exp=TR.conditionalIR(#exp(trexp(test, break)), #exp(trexp(then', break)), 
                    case else' of SOME(elseopt) => #exp(trexp(elseopt, break))
                      | NONE => TR.NIL
                    ), ty= #ty(trexp (then', break))})     
              | trexp (A.BreakExp(pos), break) = if !loopdepth > 0 
              		then (scopeUp; loopdepth:= !loopdepth-1;{exp=TR.breakIR(break),ty=T.NIL})
              		else (E.error pos "break not in loop!"; {exp=TR.nilIR(), ty=T.NIL})      
                                          
                        
          in 
            trexp (exp, break)
        end
    fun transProg(exp) = let
      val lbl = Temp.newlabel()
      val lvl = TR.newLevel{parent=TR.outermost, name=lbl, formals=[]}
      val e = #exp(transExp(venv, tenv, Find.findEscape(exp), lbl, lvl))
    in
      (seenTypes:= [];
        seenFns:= [];
        TR.procEntryExit{body=e, level=lvl};
        Printtree.printtree(TextIO.stdOut, TR.unNx(e));
        TR.getResult())
    end
       
                 
end
