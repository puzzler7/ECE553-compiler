signature FRAME =
sig type frame
    type access
    type register = string

    val newFrame: {name: Temp.label,formals: bool list} -> frame
    val name: frame -> Temp.label
    val formals: frame -> access list
    val allocLocal: frame -> bool -> access

    val FP: Temp.temp
    val RV: Temp.temp
    val RA: Temp.temp
    val V0: Temp.temp
    val V1: Temp.temp
    val A0: Temp.temp
    val A1: Temp.temp
    val A2: Temp.temp
    val A3: Temp.temp
    val ZERO: Temp.temp
    val SP: Temp.temp
    val GP: Temp.temp	
    val callersaves: Temp.temp list	
    val tempMap: register Temp.Table.table
    val registerNames: register list		       
    val wordSize: int
    val exp: access  -> Tree.exp -> Tree.exp

    datatype frag = PROC of {body: Tree.stm,  frame: frame}
                   | STRING of Temp.label  * string

    val externalCall: string * Tree.exp list -> Tree.exp
    val procEntryExit1: frame * Tree.exp -> Tree.exp
    val procEntryExit2: frame * Assem.instr list -> Assem.instr list
end
