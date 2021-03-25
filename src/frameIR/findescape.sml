signature FINDESCAPE = 
sig
    val findEscape: Absyn.exp -> Absyn.exp
end

structure FindEscape: FINDESCAPE =
struct
    structure S = Symbol

    datatype envEntry = EscapeEntry of { scopeLevel: int, escape: bool ref }

    val env: (envEntry Symbol.table) ref = ref S.empty

    fun findEscape(exp) = exp;

    fun transVar (A.SimpleVar(sym, pos), level) = 
    	case S.look((!env), sym) of
            SOME EscapeEntry({ scopeLevel, escape }) => ( 
                if scopeLevel < level then escape := true else () 
            )
            | NONE => (E.error pos "Variable does not exist!"; T.NIL)
      | transVar (A.FieldVar(var, sym, pos), level) = 
      		transVar (var, level)
      | transVar (venv, tenv, A.SubscriptVar(var, exp, pos)) = 
      	    (transVar (var, level); transExp(exp, level))
	    
       
    and transDec(dec, level) = 
    	let
	    	fun trdec (A.VarDec({name, escape, typ=NONE, init, pos})) = 
	            let 
	                val {exp,ty} = transExp(venv,tenv,init) 
	            in  
	                (venv:=S.enter(!venv,name,EscapeEntry{ scopeLevel = level+1, escape = escape}))
	            end
	      | trdec (venv, tenv, A.VarDec({name, escape, typ=SOME(x), init, pos})) = 
	            let 
	                val {exp,ty} = transExp(venv,tenv,init) 
	            in  
	                if checkTypeEqual(lookupType(!tenv, #1 x, #2 x), ty) then 
	                	{tenv=tenv, venv = (venv := S.enter(!venv,name,Env.VarEntry{ty=lookupType(!tenv, #1 x, #2 x)}); venv)}
	                else (E.error pos "named type does not match expression";{tenv=tenv, venv=venv})
	            end
	      | trdec (venv,tenv,A.TypeDec[{name,ty,pos}]) = {venv=venv,tenv=(tenv:= S.enter(!tenv, name, T.NAME(name, ref NONE));
						(case S.look(!tenv, name) of SOME(T.NAME(n, r)) => (r := SOME(transTy(tenv, ty)); if existsCycle(T.NAME(n,r)) then (raise CycleInTypeDec) else ())); if checkIfSeen(name, !seenTypes) then E.error pos "repeated type name in typedec" else seenTypes:= name:: !seenTypes;tenv)}
	      | trdec (venv,tenv,A.TypeDec({name,ty,pos}::tydeclist)) = (tenv := S.enter(!tenv, name, T.NAME(name, ref NONE)); trdec(venv, tenv, A.TypeDec(tydeclist));
									    (case S.look(!tenv, name) of SOME(T.NAME(n, r)) => (r := SOME(transTy(tenv, ty)); if existsCycle(T.NAME(n,r)) then (raise CycleInTypeDec) else ())); if checkIfSeen(name, !seenTypes) then E.error pos "repeated type name in typedec" else seenTypes:= name:: !seenTypes;{venv=venv,tenv=tenv})
	      | trdec (venv,tenv, A.FunctionDec[{name,params,body,pos,result}]) = (funcDecl(name, params, result, pos); if checkTypeEqual(funcBody(name, params, result, pos), #ty(transExp(venv, tenv, body))) then () else E.error pos "function body and return type differ"; scopeUp;{venv = venv, tenv = tenv})
	      | trdec (venv, tenv, A.FunctionDec({name,params,body,pos,result}::fundeclist)) = (funcDecl(name, params, result, pos);trdec(venv, tenv, A.FunctionDec(fundeclist)); if checkTypeEqual(funcBody(name, params, result, pos), #ty(transExp(venv, tenv, body))) then () else E.error pos "function body and return type differ"; scopeUp; {venv = venv, tenv = tenv})				
	    in
	    	(seenFns := []; seenTypes:= []; trdec(venv, tenv, dec))
	    end				    

    and transExp (venv, tenv, exp, break, level) = 
        let fun trexp (A.NilExp, break) = {exp=TR.nilIR(), ty=T.NIL}
              | trexp (A.IntExp(ival), break) = {exp=TR.intIR(ival), ty=T.INT}
              | trexp (A.StringExp(sval), break) = {exp=(), ty=T.STRING}
              | trexp (A.VarExp(lvalue), break) = transVar(venv, tenv, lvalue)
              | trexp (A.WhileExp({test, body, pos}), break) = (checkInt(trexp (test, break), pos); if #ty(trexp (body, break))=T.UNIT then (scopeDown; loopdepth:= !loopdepth+1;()) else (E.error pos "while loop must be unit"); 
                let val newbreak = Temp.newlabel() in {exp = TR.whileIR(#exp (trexp (test, break)), #exp (trexp (body, break)), newbreak), ty = T.UNIT} end)
              | trexp (A.ForExp({var, escape, lo, hi, body, pos}), break) = 
              	(scopeDown; (*Remove this scopedown now that we're turning it into a let/while?*)
              	 venv:=S.enter(!venv, var, Env.VarEntry{ty=T.INT});
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
              	val expty = (scopeDown; map (fn(x)=>(transDec(venv,tenv,x))) decs; trexp (body, break))
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

              | trexp (A.AssignExp({var, exp, pos}), break) = (if checkTypeEqual(#ty(transVar(venv, tenv, var)), #ty(trexp (exp, break))) then () else E.error pos "Assigning wrong type to variable"; {exp = TR.assignIR(var, exp), ty=T.UNIT})  
              | trexp (A.SeqExp(exps), break) = foldl (fn(x, y) => (trexp (#1 x, break))) T.UNIT exps
              | trexp (A.CallExp({func, args, pos}), break) = (case S.look(!venv, func) of SOME x =>
                                                (case x of  Env.FunEntry({formals, result}) => (checkArgs(formals, map (fn (x) => #ty(trexp (x, break))) args, pos); {exp = (), ty = result})
                                                      | Env.VarEntry({ty})  => (E.error pos "Variable is not function"; {exp = TR.nilIR(), ty = T.NIL}))
                                                                       
                                                  | NONE => (E.error pos "Variable undefined"; {exp = TR.nilIR(), ty = T.NIL}))
                                                                                                                                                                                    
              | trexp (A.ArrayExp({typ, size, init, pos}), break) = (
              	checkInt(trexp (size, break), pos); 
              	(case getArrayFromName(lookupType(!tenv, typ, pos)) of
              		T.ARRAY(ty, u) => if checkTypeEqual(ty,#ty(trexp (init, break))) then () 
              				  else E.error pos "Initializing array with wrong type"
				  | x => (E.error pos "array type mismatch"));
		
              	{exp = TR.arrayVar(size, init), ty = lookupType(!tenv, typ, pos)})

              | trexp (A.RecordExp({fields, typ, pos}), break) = 
              		(case getRecordFromName(lookupType(!tenv, typ, pos)) of
                      T.RECORD(symlist, u) => if checkRecordType(fields, symlist) 
	                      then {exp=(), ty=T.RECORD(symlist, u)} 
	                      else (E.error pos "Wrong record type!"; {exp=TR.nilIR(), ty=T.NIL})
                    | x => (E.error pos "Assigning record to not record type"; {exp=TR.nilIR(), ty=T.NIL}))
              | trexp (A.IfExp({test, then', else', pos}), break) = (checkInt(trexp (test, break), pos); 
              	(case else' of 
              		NONE => if checkTypeEqual(#ty(trexp (then', break)), T.UNIT) then () else E.error pos "If returns non-unit"
                  | SOME x => if (checkTypeEqual(#ty(trexp (then', break)), #ty(trexp (x, break))) orelse checkTypeEqual(#ty(trexp (x, break)), #ty(trexp (then', break)))) then () else E.error pos "Then Else disagree");
                  {exp=(), ty= #ty(trexp (then', break))})     
              | trexp (A.BreakExp(pos), break) = if !loopdepth > 0 
              		then (scopeUp; loopdepth:= !loopdepth-1;{exp=TR.breakIR(break),ty=T.NIL})
              		else (E.error pos "break not in loop!"; {exp=TR.nilIR(), ty=T.NIL})      
                                          
                        
          in 
            trexp (exp, break)
        end
    fun transProg(exp) = (seenTypes:= []; seenFns:= [];transExp(venv, tenv, exp);()) 
end