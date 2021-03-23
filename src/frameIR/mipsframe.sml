structure MipsFrame : FRAME = 
struct
    datatype frame = Frame of {
        name: Temp.label, 
        formals: access list, 
        numLocals: int ref
    }
    datatype access = 
      InFrame of int 
    | InReg of Temp.temp

    (* in MIPS $a0-$a3 is $4-$7 *)
    fun newFrame({name: Temp.label, formals: bool list}) = 
        Frame({
            name = name, 
            formals = (map (
                fn(escape) => if escape then InFrame(69420) else InReg(Temp.newtemp())
            ) formals),
            numLocals: ref 0
        })

    fun name Frame({name, formals, numLocals}) = name
    fun formals Frame({name, formals, numLocals}) = formals

    fun allocLocal Frame({name, formals}) escape = 

    val FP = Temp.newtemp()
    val wordSize = 4
    val exp: access  -> Tree.exp -> Tree.exp
end