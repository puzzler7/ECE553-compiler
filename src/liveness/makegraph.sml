structure MakeGraph:
sig
    val instrs2graph: Assem.instr list ->Flow.flowgraph * Graph.node list
end = 
struct
    structure A = Assem
    structure F = Flow
    structure G = Graph
    fun instrs2graph(alist) = let
        val emptygraph = F.FGRAPH{control=G.newGraph(),
                                     defs=G.Table.empty, (*Need to specify types on these?*)
                                     uses=G.Table.empty,
                                     ismove=G.Table.empty}
        fun help(g, []) = (g, [])
          | help(g, a::b) = (g, nodify(g, a)::(#2(help(g, b))))

        (*nodify needs to add edge, make new node, and return new node*)
        and nodify(F.FGRAPH{control: Graph.graph,
                                    def: Temp.temp list Graph.Table.table,
                                    use: Temp.temp list Graph.Table.table,
                                    ismove: bool Graph.Table.table}, A.OPER{assem, dst, src, jump}) = G.newNode(control)
          | nodify(F.FGRAPH{control: Graph.graph,
                                    def: Temp.temp list Graph.Table.table,
                                    use: Temp.temp list Graph.Table.table,
                                    ismove: bool Graph.Table.table}, A.LABEL{assem, lab}) = G.newNode(control)
          | nodify(F.FGRAPH{control: Graph.graph,
                                    def: Temp.temp list Graph.Table.table,
                                    use: Temp.temp list Graph.Table.table,
                                    ismove: bool Graph.Table.table}, A.MOVE{assem, dst, src}) = G.newNode(control)
    in
        help(emptygraph, alist)
    end
end