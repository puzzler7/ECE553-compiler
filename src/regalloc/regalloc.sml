(* smol brain no spill no coalesce regalloc ecksdee *)

signature REG_ALLOC = 
sig
    type allocation = MipsFrame.register Temp.Table.table
    (* because there "is no spill" alloc should return same allocation as color *)
    (* val alloc : Assem.instr list * MipsFrame.frame -> Assem.instr list * allocation *)
    val color: {
        interference: Liveness.igraph, 
        initial: allocation,
        spillCost: Graph.node -> int, 
        registers: MipsFrame.register list
    } -> allocation
end

structure RegAlloc : REG_ALLOC = 
struct
    structure TT = Temp.Table
    type allocation = MipsFrame.register Temp.Table.table

    val regCount = 24 (* very hmm *)

    fun color {
        interference = Liveness.IGRAPH ({
            graph: Graph.graph,
            tnode: Temp.temp  -> Graph.node,
            gtemp: Graph.node  -> Temp.temp,
            moves:  (Graph.node * Graph.node) list
        }), 
        initial: allocation,
        spillCost: Graph.node -> int, 
        registers: MipsFrame.register list
    } = 
    let
        val nodes = Graph.nodes graph
        val nodesOnly = map (fn(node) => Graph.exposeNode'(node)) nodes
        val nodeCount = List.length(nodes)
        val adjList = Array.array(nodeCount, [])
        val degree = Array.array(nodeCount, 0)

        val simplifyWorklist: Graph.node' list ref = ref []
        val selectStack: Graph.node' list ref = ref []
        val coloredNodes: Graph.node' list ref = ref []

        val coloring: allocation ref = ref initial

        fun build() = map(
            fn node => (
                Array.update(adjList, Graph.exposeNode'(node), map Graph.exposeNode' (Graph.adj(node)));
                Array.update(degree, Graph.exposeNode'(node), List.length(Graph.adj(node)))
            )
        )(nodes)

        fun makeWorklist(node::rest) = (
            makeWorklist(rest); 
            if (Array.sub(degree, node) < regCount) 
            then simplifyWorklist := node::(!simplifyWorklist)
            else ()
        )
        |   makeWorklist([]) = ()

        fun getAdjacent(node) = List.filter(
            fn (adjListNode) => (not (List.exists (fn(selectStackNode) => selectStackNode = adjListNode) (!selectStack)))
        )(Array.sub(adjList, node))

        fun decrementDegree(node) = 
        let
            val d = Array.sub(degree, node)
        in (
            Array.update(degree, node, d-1);
            if d = regCount 
            then simplifyWorklist := node::(!simplifyWorklist)
            else ()
        ) end

        (* call this on simplifyWorklist *)
        fun simplify(node::restOfSimplifyWorklist) = ( 
            simplifyWorklist := restOfSimplifyWorklist;
            selectStack := node::(!selectStack);
            map decrementDegree (getAdjacent(node));
            simplify(restOfSimplifyWorklist)
        )
        | simplify([]) = ()

        (* call this on selectStack *)
        fun assignColors(node::restOfSelectStack) = 
        let
            val okColors = List.filter(
                fn(registerName) => (
                    not (
                        List.exists (
                            fn(adjListNode) => (
                                case TT.look(!coloring, gtemp(Graph.constructNode(graph, adjListNode))) of
                                    NONE => false
                                |   SOME(color) => registerName = color
                            )
                        ) (Array.sub(adjList, node))
                    )
                )
            )(registers)
        in
        (
            case okColors of
            [] => ErrorMsg.error 0 "no colors available wtf"
            | someColor::otherColors => (
                coloring := TT.enter(!coloring,  gtemp(Graph.constructNode(graph, node)), someColor);
                coloredNodes := node::(!coloredNodes)
            );
            assignColors(restOfSelectStack)
        )
        end
        |   assignColors([]) = ()
    in
    (
        build();
        makeWorklist(nodesOnly);
        simplify(!simplifyWorklist);
        assignColors(!selectStack);
        (!coloring)
    )
    end

end