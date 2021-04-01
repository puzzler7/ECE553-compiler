signature FRAME =
sig type frame
    type access
    
    val newFrame: {name: Temp.label,formals: bool list} -> frame
    val name: frame -> Temp.label
    val formals: frame -> access list
    val allocLocal: frame -> bool -> access

    val FP: Temp.temp
    val RV: Temp.temp
    val RA: Temp.temp
    val wordSize: int
    val exp: access  -> Tree.exp -> Tree.exp

    datatype frag = PROC of {body: Tree.stm,  frame: frame}
                   | STRING of Temp.label  * string

    val externalCall: string * Tree.exp list -> Tree.exp
    val procEntryExit1: frame * Tree.exp -> Tree.exp
end