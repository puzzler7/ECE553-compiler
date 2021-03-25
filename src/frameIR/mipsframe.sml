structure MipsFrame : FRAME = 
struct
    val wordSize = 4
    val frameSize = 96

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
        let fun getAssign ([], n) = []
            |   getAssign (head::formalsList, n) = (if head then InFrame(n*4) else InReg(Temp.newtemp()))::(getAssign(formalsList, n + 1))
        in
            Frame({
                name = name, 
                formals = getAssign(formals, 0),
                numLocals = ref 0
            })
        end

    fun name Frame({name, formals, numLocals}) = name
    fun formals Frame({name, formals, numLocals}) = formals

    fun allocLocal Frame({name, formals, numLocals}) false = (
        numLocals := !numLocals + 1; 
        InReg(Temp.newtemp())
    )
    |   allocLocal Frame({name, formals, numLocals}) true = (
        numLocals := !numLocals + 1; 
        InFrame(frameSize - 4 * !numLocals)
    )

    val FP = Temp.newtemp()
    val RA = Temp.newtemp()

    fun exp (InFrame(i)) fp = Tree.MEM(Tree.BINOP(Tree.PLUS, fp, Tree.CONST(i)))
      | exp (InReg(reg)) fp = Tree.TEMP(reg)

    fun externalCall(s, args) = Tree.CALL(Tree.NAME(Temp.namedlabel s), args)
end