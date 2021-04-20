(* smol brain no spill no coalesce regalloc ecksdee *)

signature REG_ALLOC = 
sig
    structure Frame : FRAME
    type allocation = Frame.register Temp.Table.table
    (* because there "is no spill" alloc should return same allocation as color *)
    val alloc : Assem.instr list * Frame.frame -> Assem.instr list * allocation
    val color: {
        interference: Liveness.igraph, 
        initial: allocation,
        spillCost: Graph.node -> int, 
        registers: Frame.register list
    } -> allocation * Temp.temp list
    val build: unit -> unit
    val makeWorklist: unit -> unit
    val assignColors: unit -> unit
    val decrementDegree: Temp.temp -> unit

    val precolored: Frame.register Temp.Table.table
    val initial: Frame.register Temp.Table.table
    val simplifyWorklist: Graph.node' list

    val selectStack: Graph.node' list

    val adjSet: sumsing
    val adjList: Graph.node' list list
    val degree: int list
end

structure RegAlloc : REG_ALLOC = 
struct
    structure TT = Temp.Table

    val regCount = 29 (* very hmm *)

    fun color {
        interference = Liveness.IGRAPH ({
            graph: Graph.graph,
            tnode: Temp.temp  -> Graph.node,
            gtemp: Graph.node  -> Temp.temp,
            moves:  (Graph.node * Graph.node) list
        }), 
        initial: allocation,
        spillCost: Graph.node' -> int, 
        registers: Frame.register list
    } = 
    let
        val nodes = Graph.nodes graph
        val nodesOnly = map (fn(g,i) => i) nodes
        val nodeCount = List.length(nodes)
        val adjList: Graph.node' list list = Array.array(nodeCount, [])
        val degree = Array.array(nodeCount, 0)

        val simplifyWorklist: Graph.node' list ref = ref []
        val selectStack: Graph.node' list ref = ref []
        val coloredNodes: Graph.node' list ref = ref []

        val coloring: allocation ref = ref initial

        fun build() = map(
            fn (g,i) => (
                Array.update(adjList, i, Graph.succ(g,i) @ Graph.pred(g,i));
                Array.update(degree, i, List.length(Graph.succ(g,i) @ Graph.pred(g,i)))
            )
        )(nodes)

        fun makeWorklist(node::rest) = (
            makeWorklist(rest); 
            if (Array.sub(degree, node) < regCount) 
            then simplifyWorklist := node::!simplifyWorklist
            else ()
        )
        |   makeWorklist([]) = ()

        fun getAdjacent(node) = List.filter(
            fn (adjListNode) => (not (List.exists (fn(selectStackNode) => selectStackNode = adjListNode) !selectStack))
        )(Array.sub(adjList, node))

        fun decrementDegree(node) = 
        let
        val d = Array.sub(degree, node)
        in (
        Array.update(degree, node, d-1);
        if d = regCount 
        then simplifyWorklist := node::!simplifyWorklist
        else ()
        ) end

        (* call this on simplifyWorklist *)
        fun simplify(node::restOfSimplifyWorklist) = ( 
            simplifyWorklist := restOfSimplifyWorklist;
            selectStack := node::!selectStack;
            map decrementDegree getAdjacent(node);
            simplifyWorklist(restOfSimplifyWorklist)
        )
        | simplify([]) = ()

        (* call this on selectStack *)
        fun assignColors(node::restOfSelectStack) = 
        let
        val okColors = List.filter(
            fn(registerName) => (
                not List.exists (
                    fn(adjListNode) => (
                        case TT.look(coloring, gtemp(graph, node)) of
                            NONE => false
                        |   SOME(color) => registerName = color
                    )
                ) !adjList
            )
        )(registers)
        in
        (
            case okColors of
            [] => ErrorMsg.error 0 "no colors available wtf"
            | someColor::otherColors => (
                coloring := TT.enter(!coloring, gtemp(graph, node), someColor);
                coloredNodes := node::!coloredNodes
            );
            assignColors(restOfSelectStack)
        )
        end
        |   assignColors([]) = ()
    in
    (
        build();
        makeWorklist(nodesOnly);
        simplify(simplifyWorklist);
        assignColors(selectStack);
        coloring
    )
    end

end