structure Main = struct

   structure Tr = Translate
   structure F = MipsFrame
   structure TigerLrVals = TigerLrValsFun(structure Token = LrParser.Token)
   structure Lex = TigerLexFun(structure Tokens = TigerLrVals.Tokens)
   structure TigerP = Join(structure ParserData = TigerLrVals.ParserData
    structure Lex=Lex
    structure LrParser = LrParser)
   structure R = RegAlloc
   
 fun getsome (SOME x) = x

 fun magicTempMapper(alloc: R.allocation)(t: Temp.temp) = 
        case Temp.Table.look(alloc, t) of 
          SOME(x) => x
        | NONE => (ErrorMsg.error 0 ("Temp " ^ (Temp.makestring t) ^  " not found in regalloc!"); Temp.makestring t)

 fun emitproc out (F.PROC{body,frame}) =
     let val _ = print ("emit " ^ Symbol.name(F.name(frame)) ^ "\n")
(*         val _ = Printtree.printtree(out,body); *)
	 val stms = Canon.linearize body
(*         val _ = app (fn s => Printtree.printtree(out,s)) stms; *)
         val stms' = Canon.traceSchedule(Canon.basicBlocks stms) 
	     val instrs = List.concat(map (MIPSGen.codegen frame) stms') 

       val entryexited = F.procEntryExit3(frame, F.procEntryExit2(frame, instrs))
       
       val igraph = #1(Liveness.interferenceGraph(#1(MakeGraph.instrs2graph(#body entryexited))))
       val alloc = RegAlloc.color({ interference=igraph, initial=MipsFrame.tempMap, spillCost=(fn(_)=>1), registers=MipsFrame.registerNames})
       

       val format0 = Assem.format(magicTempMapper(alloc))
     in  (TextIO.output(out, ".text\n");TextIO.output(out, #prolog entryexited);
             app (fn i => TextIO.output(out,format0 i)) instrs;
              TextIO.output(out, #epilog entryexited))     
     end
   | emitproc out (F.STRING(lab,s)) = (TextIO.output(out,F.string(lab, s)))
						   
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

   fun prolog(out) = TextIO.output(out, "\t.text\n\t.align 4\ntig_main: \n ")

   fun epilog(out) = let
     val runFile = TextIO.openIn("runtime-le.s")
        val sysFile = TextIO.openIn("sysspim.s")
        val runText = TextIO.inputAll(runFile)
        val sysText = TextIO.inputAll(sysFile)          
   in
     (TextIO.output(out, "\n"); TextIO.output(out, runText); TextIO.output(out, sysText))
   end

   fun compile filename = 
       let val absyn = parse(filename)
           val frags = (FindEscape.findEscape absyn; Semant.transProg absyn)
        in 
            ((*print("final fraglist length: "^Int.toString(List.length(frags))^"\n");*)
              withOpenFile (filename ^ ".s") 
	     (fn out => (prolog(out); app (emitproc out) frags; epilog(out))))
       end

end

