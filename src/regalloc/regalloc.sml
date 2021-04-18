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
    val simplifyWorklist: Graph.node list

    val selectStack: Graph.node list

    val adjSet: sumsing
    val adjList: Graph.node list list
    val degree: int list
end

structure RegAlloc : REG_ALLOC = 
struct

end