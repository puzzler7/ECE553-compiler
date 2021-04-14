structure Main : sig 
	val parse : string -> Absyn.exp
	val main : string -> MipsFrame.frag list
	val typecheckOnly : string -> MipsFrame.frag list
	val print_intermediate: string -> MipsFrame.frag list
end =
struct 
	structure TigerLrVals = TigerLrValsFun(structure Token = LrParser.Token)
	structure Lex = TigerLexFun(structure Tokens = TigerLrVals.Tokens)
	structure TigerP = Join(structure ParserData = TigerLrVals.ParserData
		structure Lex=Lex
		structure LrParser = LrParser)
	fun parse filename =
		let val _ = (ErrorMsg.reset(); ErrorMsg.fileName := filename)
			val file = TextIO.openIn filename
			fun get _ = TextIO.input file
			fun parseerror(s,p1,p2) = ErrorMsg.error p1 s
				val lexer = LrParser.Stream.streamify (Lex.makeLexer get)
				val (absyn, _) = TigerP.parse(30,lexer,parseerror,())
		in TextIO.closeIn file;
			absyn
		end handle LrParser.ParseError => raise ErrorMsg.Error

	fun main filename = 
		let val tree = parse(filename)
		in
			(*(PrintAbsyn.print(TextIO.stdOut, tree);*)
			Semant.transProg(tree)
		end
	
	fun typecheckOnly filename = 
		let val tree = parse(filename)
		in
			Semant.transProg(tree)
		end

	fun print_intermediate filename =
    let
      val ast = parse filename
      val _ = FindEscape.findEscape ast
    in  
      Semant.transProg ast
    end
end



