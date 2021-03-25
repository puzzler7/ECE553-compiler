signature FRAME =
sig type frame
    type access
    type frag
    
    val newFrame: {name: Temp.label,formals: bool list} -> frame
    val name: frame -> Temp.label
    val formals: frame -> access list
    val allocLocal: frame -> bool -> access

    val FP: Temp.temp
    val wordSize: int
    val exp: access  -> Tree.exp -> Tree.exp

    val externalCall: string * Tree.exp list -> Tree.exp
    val procEntryExit1: frame * Tree.exp -> unit
end