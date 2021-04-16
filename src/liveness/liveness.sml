structure Liveness:
sig
    datatype igraph = IGRAPH of {graph: Graph.graph,
                                tnode: Temp.temp  -> Graph.node,
                                gtemp: Graph.node  -> Temp.temp,
                                moves:  (Graph.node * Graph.node) list}
    val interferenceGraph :Flow.flowgraph ->igraph * (Flow.Graph.node  -> Temp.temp list)

    (*val show  : outstream * igraph -> unit*)
end =
struct
    structure A = Assem
    structure F = Flow
    structure G = Graph
    structure T = G.Table
    structure S = Symbol

    datatype igraph = IGRAPH of {graph: Graph.graph,
                                tnode: Temp.temp  -> Graph.node,
                                gtemp: Graph.node  -> Temp.temp,
                                moves:  (Graph.node * Graph.node) list}

    fun interferenceGraph (F.FGRAPH{control, def, use, ismove}) = let
        fun igraphify() = IGRAPH({graph=G.newGraph(), tnode=(fn(x)=>G.newNode(G.newGraph()),
                            gtemp=(fn(x)=>Temp.newTemp()), moves=[])})
    in
        (igraphify(), livify()))
    end
end