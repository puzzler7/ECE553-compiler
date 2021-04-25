structure MakeGraph:
	  sig
	      val show: TextIO.outstream * Flow.flowgraph -> unit
  val instrs2graph: Assem.instr list ->Flow.flowgraph * Graph.node list
end = 
struct
  structure A = Assem
  structure F = Flow
  structure G = Graph
  structure T = G.Table
  structure S = Symbol

   fun show (out, F.FGRAPH{control=gr, def=d, use=u, ismove=mv}) = let
      fun pr(s) = TextIO.output(out, s)
      fun prNode(n) = pr(G.nodename(n))
      fun prNodeList([]) = pr("\n")
        | prNodeList(a::b) = (prNode(a); pr(", "); prNodeList(b))
      fun prGraphNodes([]) = ()
        | prGraphNodes(a::b) = (prNode(a); pr(": "); prNodeList(G.pred(a)); prGraphNodes(b))
    in
      prGraphNodes(G.nodes(gr))
    end

  fun instrs2graph(alist) = let
    val emptygraph = F.FGRAPH{control=G.newGraph(),
    def=T.empty, (*Need to specify types on these?*)
    use=T.empty,
    ismove=T.empty}
    (*nodify needs to add edge, make new node, and return new node*)
     val lTable: G.node S.table ref = ref S.empty
     
     fun nodify(F.FGRAPH{control: Graph.graph,
      def: Temp.temp list Graph.Table.table,
      use: Temp.temp list Graph.Table.table,
      ismove: bool Graph.Table.table}, A.OPER{assem, dst, src, jump}, nodelist) = let val ret = G.newNode(control)
										  in
										      (F.FGRAPH{control=control, def = T.enter(def, ret, dst), use = T.enter(use, ret, src), ismove = T.enter(ismove, ret, false)}, ret::nodelist)
     end
     
     | nodify(F.FGRAPH{control: Graph.graph,
      def: Temp.temp list Graph.Table.table,
      use: Temp.temp list Graph.Table.table,
      ismove: bool Graph.Table.table}, A.LABEL{assem, lab}, nodelist) = let val ret = G.newNode(control)
     in
      (lTable:= S.enter(!lTable, lab, ret); (F.FGRAPH{control=control, def = T.enter(def, ret, []), use = T.enter(use, ret, []), ismove = T.enter(ismove, ret, false)}, ret::nodelist))
    end
    | nodify(F.FGRAPH{control: Graph.graph,
      def: Temp.temp list Graph.Table.table,
      use: Temp.temp list Graph.Table.table,
      ismove: bool Graph.Table.table}, A.MOVE{assem, dst, src}, nodelist) = let val ret = G.newNode(control)
    in
      (F.FGRAPH{control=control, def = T.enter(def, ret, [dst]), use = T.enter(use, ret, [src]), ismove = T.enter(ismove, ret, true)}, ret::nodelist)
    end
    fun lookup(x) = case S.look(!lTable, x) of SOME x => x (* case nonexhaustive should never occur *)
                            | NONE => (print("Can't find"^S.name(x)^"\n"); G.newNode(G.newGraph()))
      
     fun edgify([node], [A.OPER{assem, dst, src, jump=SOME(j)}]) = (map (fn x => G.mk_edge{from=node, to=lookup(x)}) j; ())
       | edgify([node], [assem]) = ()					 
       | edgify(node1::(node2::nlist), A.OPER{assem, dst, src, jump=NONE}::(assem2::alist)) = (G.mk_edge{from=node1, to = node2}; edgify(node2::nlist, assem2::alist)) 
       | edgify(node1::(node2::nlist), A.OPER{assem, dst, src, jump=SOME(j)}::(assem2::alist)) = (print(assem ^ " " ^ G.nodename(node1) ^ "\n");map (fn x => G.mk_edge{from=node1, to=lookup(x)}) j; edgify(node2::nlist, assem2::alist))
       | edgify(node1::(node2::nlist), assem1::(assem2::alist))  =  (G.mk_edge{from=node1, to=node2}; edgify(node2::nlist, assem2::alist)) 				
       
     in
	 let val gnlist = foldr (fn (x, y) => nodify(#1(y), x, #2(y)))  (emptygraph ,[]) alist
				 
      in
	  (edgify(#2(gnlist), alist); gnlist)
     end        
   end
 end
