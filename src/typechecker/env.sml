structure ENV = 
struct
	structure S = Symbol
	structure T = Types
	type access = unit	
	type ty = Types.ty
	datatype enventry = VarEntry of {ty: ty}
					  | FunEntry of {formals: ty list, result: ty}
	val base_tenv = S.enter(S.enter(S.empty, S.symbol "int", T.INT), S.symbol "string", T.STRING)
	val base_venv : enventry S.table  (* predefined functions, these all need to be added, from appendix A*)
end