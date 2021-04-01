structure Env = 
struct
	structure S = Symbol
	structure T = Types
	structure TR = Translate
	type access = unit	
	type ty = Types.ty
	datatype enventry = VarEntry of {access: Translate.access, ty: ty}
		  			  | FunEntry of {level: Translate.level, label: Temp.label, formals: ty list, result: ty}
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
												FunEntry { level=TR.outermost, label=Temp.newlabel(), formals = [T.STRING], result = T.UNIT }
											),
											S.symbol "flush",
											FunEntry { level=TR.outermost, label=Temp.newlabel(), formals = [], result = T.UNIT }
										),
										S.symbol "getchar",
										FunEntry { level=TR.outermost, label=Temp.newlabel(), formals = [], result = T.STRING }
									),
									S.symbol "ord",
									FunEntry { level=TR.outermost, label=Temp.newlabel(), formals = [T.STRING], result = T.INT }
								),
								S.symbol "chr",
								FunEntry { level=TR.outermost, label=Temp.newlabel(), formals = [T.INT], result = T.STRING }
							),
							S.symbol "size",
							FunEntry { level=TR.outermost, label=Temp.newlabel(), formals = [T.STRING], result = T.INT }
						),
						S.symbol "substring",
						FunEntry { level=TR.outermost, label=Temp.newlabel(), formals = [T.STRING, T.INT, T.INT], result = T.STRING }
					),
					S.symbol "concat",
					FunEntry { level=TR.outermost, label=Temp.newlabel(), formals = [T.STRING, T.STRING], result = T.STRING }
				),
				S.symbol "not",
				FunEntry { level=TR.outermost, label=Temp.newlabel(), formals = [T.INT], result = T.INT }
			),
			S.symbol "exit",
			FunEntry { level=TR.outermost, label=Temp.newlabel(), formals = [T.INT], result = T.UNIT }
		)
	 (* predefined functions, these all need to be added, from appendix A*)
end