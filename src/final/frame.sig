signature FRAME =
sig type frame
    type access
    type register = string

    val newFrame: {name: Temp.label,formals: bool list} -> frame
    val name: frame -> Temp.label
    val formals: frame -> access list
    val allocLocal: frame -> bool -> access

    val frameSize: int

    val ZERO :Temp.temp
    val V0 :Temp.temp
    val RV: Temp.temp
    val V1 :Temp.temp
    val A0 :Temp.temp
    val A1 :Temp.temp
    val A2 :Temp.temp
    val A3 :Temp.temp
    val T0 :Temp.temp
    val T1 :Temp.temp
    val T2 :Temp.temp
    val T3 :Temp.temp
    val T4 :Temp.temp
    val T5 :Temp.temp
    val T6 :Temp.temp
    val T7 :Temp.temp
    val S0 :Temp.temp
    val S1 :Temp.temp
    val S2 :Temp.temp
    val S3 :Temp.temp
    val S4 :Temp.temp
    val S5 :Temp.temp
    val S6 :Temp.temp
    val S7 :Temp.temp
    val T8 :Temp.temp
    val T9 :Temp.temp
    val GP :Temp.temp
    val SP :Temp.temp
    val FP :Temp.temp
    val RA :Temp.temp	
    val callersaves: Temp.temp list	
    val tempMap: register Temp.Table.table
    val registerNames: register list		       
    val wordSize: int
    val exp: access  -> Tree.exp -> Tree.exp
    val exp1: access  -> Tree.exp
    val string: Tree.label * string -> string

    datatype frag = PROC of {body: Tree.stm,  frame: frame}
                   | STRING of Temp.label  * string

    val externalCall: string * Tree.exp list -> Tree.exp
    val procEntryExit1: frame * Tree.stm -> Tree.stm
    val procEntryExit2: frame * Assem.instr list -> Assem.instr list
    val procEntryExit3 : frame * Assem.instr list -> 
            {prolog: string, body: Assem.instr list, epilog: string}
end
