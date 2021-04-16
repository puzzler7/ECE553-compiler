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

    type liveSet = unit Temp.Table.table * temp list
    type liveMap = liveSet  Flow.Graph.Table.table

    datatype igraph = IGRAPH of {graph: Graph.graph,
                                tnode: Temp.temp  -> Graph.node,
                                gtemp: Graph.node  -> Temp.temp,
                                moves:  (Graph.node * Graph.node) list}

    fun interferenceGraph (F.FGRAPH{control, def, use, ismove}) = let
        fun igraphify() = IGRAPH({graph=G.newGraph(), tnode=(fn(x)=>G.newNode(G.newGraph()),
                            gtemp=(fn(x)=>Temp.newTemp()), moves=[])})

        fun livify({fcontrol, fdef, fuse, fismove}) = let
            (*initialize in, out*)
            val intable = foldr (fn(x, y)=>T.enter(y, x, IntListSet.empty())) T.empty G.nodes(fcontrol)
            val outtable = foldr (fn(x, y)=>T.enter(y, x, IntListSet.empty())) T.empty G.nodes(fcontrol)
            fun iter(intab, outab) = let
                val in' = intab
                val out' = outab
                val fintable = foldr (fn(x, y)=>T.enter(y, x, IntListSet.empty())) T.empty G.nodes(fcontrol)
                val fouttable = foldr (fn(x, y)=>T.enter(y, x, IntListSet.empty())) T.empty G.nodes(fcontrol)

                fun coerce (SOME(x)) = x
            in
                if intab = fintable andalso outab = fouttable then return happy else iter(fintable, fouttable)
            end
        in
            body
        end
    in
        (igraphify(), livify({control, def, use, ismove})))
    end
end