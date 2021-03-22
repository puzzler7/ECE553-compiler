structure Env = 
struct
	structure S = Symbol
	structure T = Types
	type access = unit	
	type ty = Types.ty
	datatype enventry = VarEntry of {ty: ty}
					  | FunEntry of {formals: ty list, result: ty}
	val base_tenv = S.enter(S.enter(S.empty, S.symbol "int", T.INT), S.symbol "string", T.STRING)
	val base_venv : enventry S.table =
		S.enter(
			S.enter(
				S.enter(
					S.enter(
						S.enter(
							S.enter(
								S.enter(
									S.enter(
										S.enter(
											S.enter(
												S.empty,
												S.symbol "print",
												FunEntry { formals = [T.STRING], result = T.UNIT }
											),
											S.symbol "flush",
											FunEntry { formals = [], result = T.UNIT }
										),
										S.symbol "getchar",
										FunEntry { formals = [], result = T.STRING }
									),
									S.symbol "ord",
									FunEntry { formals = [T.STRING], result = T.INT }
								),
								S.symbol "chr",
								FunEntry { formals = [T.INT], result = T.STRING }
							),
							S.symbol "size",
							FunEntry { formals = [T.STRING], result = T.INT }
						),
						S.symbol "substring",
						FunEntry { formals = [T.STRING, T.INT, T.INT], result = T.STRING }
					),
					S.symbol "concat",
					FunEntry { formals = [T.STRING, T.STRING], result = T.STRING }
				),
				S.symbol "not",
				FunEntry { formals = [T.INT], result = T.INT }
			),
			S.symbol "exit",
			FunEntry { formals = [T.INT], result = T.UNIT }
		)
	 (* predefined functions, these all need to be added, from appendix A*)
end