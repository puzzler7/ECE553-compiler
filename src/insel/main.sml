structure Main = struct

   structure Tr = Translate
   structure F = MipsFrame
   structure TigerLrVals = TigerLrValsFun(structure Token = LrParser.Token)
   structure Lex = TigerLexFun(structure Tokens = TigerLrVals.Tokens)
   structure TigerP = Join(structure ParserData = TigerLrVals.ParserData
    structure Lex=Lex
    structure LrParser = LrParser)
   
 fun getsome (SOME x) = x

 fun emitproc out (F.PROC{body,frame}) =
     let val _ = print ("emit " ^ Symbol.name(F.name(frame)) ^ "\n")
(*         val _ = Printtree.printtree(out,body); *)
	 val stms = Canon.linearize body
(*         val _ = app (fn s => Printtree.printtree(out,s)) stms; *)
         val stms' = Canon.traceSchedule(Canon.basicBlocks stms) 
	 val instrs =   List.concat(map (MIPSGen.codegen frame) stms') 
         val format0 = Assem.format(Temp.makestring)
     in  (app (fn i => TextIO.output(out,format0 i)) instrs)	     
     end
   | emitproc out (F.STRING(lab,s)) = TextIO.output(out,F.STRING(lab,s))
						   
   fun withOpenFile fname f = 
       let val out = TextIO.openOut fname
        in (f out before TextIO.closeOut out) 
	    handle e => (TextIO.closeOut out; raise e)
       end 

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

   fun compile filename = 
       let val absyn = parse(filename)
           val frags = (*FindEscape.prog absyn;*) Semant.transProg absyn
        in 
            withOpenFile (filename ^ ".s") 
	     (fn out => (app (emitproc out) frags))
       end

end

