signature FINDESCAPE = 
sig
    val findEscape: Absyn.exp -> Absyn.exp
end

structure FindEscape: FINDESCAPE =
struct
    structure A = Absyn
    structure S = Symbol
    structure T = Types
    structure E = ErrorMsg

    datatype envEntry = EscapeEntry of { scopeLevel: int, escape: bool ref }

    val env: (envEntry Symbol.table) ref = ref S.empty
	val stack: ((envEntry Symbol.table) list) ref = ref []

	fun scopeDown () =
        stack := !env::(!stack)
    fun scopeUp () = (
		  fn(a::l) => (env := a; stack := l) 
		    | ([]) => (E.error 177013 "Trying to scopeUp on empty escape analysis stack wtf"; ())
	) (!stack)

	fun funcBody (params, result, level) =
        let
            fun transparam{name,escape,typ,pos} = { name=name, scopeLevel=level, escape=escape }

            val params' = map transparam params


            fun enterparam ({ name, scopeLevel, escape }, env) =
                S.enter(env, name, EscapeEntry({ scopeLevel=scopeLevel, escape=escape }))
        in (scopeDown; env := foldr enterparam (!env) params')
    end

    fun transVar (A.SimpleVar(sym, pos), level) = (
            case S.look((!env), sym) of
            SOME (EscapeEntry({ scopeLevel, escape })) => ( 
                if scopeLevel < level then escape := true else () 
            )
            | NONE => ()
        )
      | transVar (A.FieldVar(var, sym, pos), level) = 
      		transVar (var, level)
      | transVar (A.SubscriptVar(var, exp, pos), level) = 
      	    (transVar (var, level); transExp(exp, level))
	    
       
    and transDec (A.VarDec({name, escape, typ, init, pos}), level) = 
				(env := S.enter(!env, name, EscapeEntry{ scopeLevel = level, escape = escape }))
	      | transDec (A.FunctionDec([{name,params,body,pos,result}]), level) = (funcBody(params, result, level+1); transExp(body, level+1); scopeUp())
	      | transDec (A.FunctionDec({name,params,body,pos,result}::fundeclist), level) = (transDec(A.FunctionDec(fundeclist), level); funcBody(params, result, level+1); transExp(body, level+1); scopeUp())				
		  | transDec (elze) = ()    


    and transExp (exp, level) = 
        let fun trexp (A.NilExp, level) = ()
              | trexp (A.IntExp(ival), level) = ()
              | trexp (A.StringExp(sval), level) = ()
              | trexp (A.VarExp(lvalue), level) = transVar(lvalue, level)
              | trexp (A.WhileExp({test, body, pos}), level) = (trexp(test, level); scopeDown; trexp(body, level+1); scopeUp())
              | trexp (A.ForExp({var, escape, lo, hi, body, pos}), level) = (
                 scopeDown;
              	 env := S.enter(!env, var, EscapeEntry({ scopeLevel=level+1, escape=escape }));
              	 trexp(lo, level+1); 
				 trexp(hi, level+1);
              	 trexp (body, level+1)
                )
              | trexp (A.LetExp({decs, body, pos}), level) = 
              let
              	val expty = (scopeDown; map (fn(x)=>(transDec(x, level+1))) decs; trexp(body, level+1))
              in
              	scopeUp()
              end
                                      
              | trexp (A.OpExp({left, oper, right, pos}), level) = 
              		(trexp(left, level); trexp(right, level))
              | trexp (A.AssignExp({var, exp, pos}), level) = (transVar(var, level); trexp(exp, level))  
              | trexp (A.SeqExp(exps), level) = (map (fn(x, y) => trexp(x, level)) exps; ())
              | trexp (A.CallExp({func, args, pos}), level) = (
				  map (fn(x) => trexp(x, level)) args;
                  ()
			  )
                                                                                                                                                                                    
              | trexp (A.ArrayExp({typ, size, init, pos}), level) = (
              	trexp(size, level); 
              	trexp (init, level)
			  )

              | trexp (A.RecordExp({fields, typ, pos}), level) = (
                    map (fn(x, y, z) => trexp(y, level)) (fields);
                    ()
                )
              | trexp (A.IfExp({test, then', else', pos}), level) = (
				  trexp (test, level); 
              	  case else' of 
              		NONE => trexp(then', level)
                  | SOME x => (trexp(then', level); trexp(x, level))
			    )
              | trexp (A.BreakExp(pos), level) = ()  
                                          
                        
          in 
            trexp (exp, level)
        end
    fun findEscape(exp) = (transExp(exp, 1); exp)
end