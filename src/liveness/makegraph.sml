structure MakeGraph:
sig
    val instrs2graph: Assem.instr list ->Flow.flowgraph * Graph.node list
end = 
struct
    structure A = Assem
    structure F = Flow
    structure G = Graph
    structure T = G.Table		      
    fun instrs2graph(alist) = let
        val emptygraph = F.FGRAPH{control=G.newGraph(),
                                     def=T.empty, (*Need to specify types on these?*)
                                     use=T.empty,
                                     ismove=T.empty}
	val prev = ref G.noode
	val labelTable  = ref T.empty
	val assemTable  = ref T.empty
	
						  (* labify should not change node list *)
(*	fun labify(F.FGRAPH{control: Graph.graph,
                                    def: Temp.temp list Graph.Table.table,
                                    use: Temp.temp list Graph.Table.table,
                                    ismove: bool Graph.Table.table}, A.OPER{assem, dst, src, jump}, nodelist) = (case jump of SOME x => G.mk_edge{from=getNode from assem, getlabel from list})
															    | NONE  => ());
*)	
				  
        (*nodify needs to add edge, make new node, and return new node*)
        fun nodify(F.FGRAPH{control: Graph.graph,
                                    def: Temp.temp list Graph.Table.table,
                                    use: Temp.temp list Graph.Table.table,
                                    ismove: bool Graph.Table.table}, A.OPER{assem, dst, src, jump}, nodelist) = let val ret = G.newNode(control)
												      in
													  (if G.isNoode((!prev)) then () else G.mk_edge{from=(!prev), to=ret};
													   (case jump of SOME x => prev:=G.noode
                                                                                                                       | NONE  => prev:=ret);						    
													   (F.FGRAPH{control=control, def = T.enter(def, ret, dst), use = T.enter(use, ret, src), ismove = T.enter(ismove, ret, false)}, ret::nodelist))
												      end
													  
          | nodify(F.FGRAPH{control: Graph.graph,
                                    def: Temp.temp list Graph.Table.table,
                                    use: Temp.temp list Graph.Table.table,
                                    ismove: bool Graph.Table.table}, A.LABEL{assem, lab}, nodelist) = let val ret = G.newNode(control)
                                                                                            in
												(if G.isNoode((!prev)) then () else G.mk_edge{from=(!prev), to=ret}; prev:= ret;
												 labelTable:=T.enter(!labelTable, lab, ret);
												 (F.FGRAPH{control=control, def = T.enter(def, ret, []), use = T.enter(use, ret, []), ismove = T.enter(ismove, ret, false)}, ret::nodelist))
											    end
	  | nodify(F.FGRAPH{control: Graph.graph,
                            def: Temp.temp list Graph.Table.table,
                                    use: Temp.temp list Graph.Table.table,
                                    ismove: bool Graph.Table.table}, A.MOVE{assem, dst, src}, nodelist) = let val ret = G.newNode(control)
												in
												    (if G.isNoode((!prev)) then () else G.mk_edge{from=(!prev), to=ret}; prev:=ret;
												     (F.FGRAPH{control=control, def = T.enter(def, ret, [dst]), use = T.enter(use, ret, [src]), ismove = T.enter(ismove, ret, true)}, ret::nodelist))													
												end
												    
			   in
			       
			       foldr (fn (x, y) => let val rv = nodify((#1 y), x, (#2 y))
						   in
						       (assemTable := T.enter(!assemTable, x, hd(#2(rv)));
							rv)
						   end
						       )
							   (emptygraph ,[]) alist
		 	       	     
				   
        
    end
end
