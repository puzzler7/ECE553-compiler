structure MipsFrame : FRAME = 
struct
    structure A = Assem
    structure TT = Temp.Table

    val wordSize = 4
    val frameSize = 96

    type register = string

    datatype access = 
      InFrame of int 
    | InReg of Temp.temp

    datatype frame = Frame of {
        name: Temp.label, 
        formals: access list, 
        numLocals: int ref
    }

    datatype frag = 
        PROC of {body: Tree.stm, frame: frame} 
    |   STRING of Temp.label * string


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

    fun name (Frame({name, formals, numLocals})) = name
    fun formals (Frame({name, formals, numLocals})) = formals

    fun allocLocal (Frame({name, formals, numLocals})) false = (
        numLocals := !numLocals + 1; 
        InReg(Temp.newtemp())
    )
    |   allocLocal (Frame({name, formals, numLocals})) true = (
        numLocals := !numLocals + 1; 
        InFrame(frameSize - 4 * !numLocals)
    )

    (* Register stuff *)
    val ZERO = Temp.newtemp()
    val V0 = Temp.newtemp()
    val RV = V0
    val V1 = Temp.newtemp()
    val A0 = Temp.newtemp()
    val A1 = Temp.newtemp()
    val A2 = Temp.newtemp()
    val A3 = Temp.newtemp()
    val T0 = Temp.newtemp()
    val T1 = Temp.newtemp()
    val T2 = Temp.newtemp()
    val T3 = Temp.newtemp()
    val T4 = Temp.newtemp()
    val T5 = Temp.newtemp()
    val T6 = Temp.newtemp()
    val T7 = Temp.newtemp()
    val S0 = Temp.newtemp()
    val S1 = Temp.newtemp()
    val S2 = Temp.newtemp()
    val S3 = Temp.newtemp()
    val S4 = Temp.newtemp()
    val S5 = Temp.newtemp()
    val S6 = Temp.newtemp()
    val S7 = Temp.newtemp()
    val T8 = Temp.newtemp()
    val T9 = Temp.newtemp()
    val GP = Temp.newtemp()
    val SP = Temp.newtemp()
    val FP = Temp.newtemp()
    val RA = Temp.newtemp()
    val specialregs = [ZERO, V0, V1, GP, SP, FP, RA]
    val argregs = [A0, A1, A2, A3]
    val callersaves = [T0, T1, T2, T3, T4, T5, T6, T7, T8, T9]
    val calleesaves = [S0, S1, S2, S3, S4, S5, S6, S7]

    val registerNames: register list = [
        (*"$v0",
        "$v1",
        "$a0",
        "$a1",
        "$a2",
        "$a3",*)
        "$t0",
        "$t1",
        "$t2",
        "$t3",
        "$t4",
        "$t5",
        "$t6",
        "$t7",
        "$s0",
        "$s1",
        "$s2",
        "$s3",
        "$s4",
        "$s5",
        "$s6",
        "$s7",
        "$t8",
        "$t9"
    ]

    fun makeRegList someList = foldl (
        fn((temp, regname), reglist) =>
            TT.enter(reglist, temp, regname)
    ) TT.empty someList

    val tempMap: register TT.table = makeRegList [
        (ZERO, "$0"),
        (V0, "$v0"),
        (V1, "$v1"),
        (A0, "$a0"),
        (A1, "$a1"),
        (A2, "$a2"),
        (A3, "$a3"),
        (T0, "$t0"),
        (T1, "$t1"),
        (T2, "$t2"),
        (T3, "$t3"),
        (T4, "$t4"),
        (T5, "$t5"),
        (T6, "$t6"),
        (T7, "$t7"),
        (S0, "$s0"),
        (S1, "$s1"),
        (S2, "$s2"),
        (S3, "$s3"),
        (S4, "$s4"),
        (S5, "$s5"),
        (S6, "$s6"),
        (S7, "$s7"),
        (T8, "$t8"),
        (T9, "$t9"),
        (GP, "$gp"),
        (SP, "$sp"),
        (FP, "$fp"),
        (RA, "$ra")
    ]

    fun exp (InFrame(i)) fp = Tree.MEM(Tree.BINOP(Tree.PLUS, fp, Tree.CONST(i)))
      | exp (InReg(reg)) fp = Tree.TEMP(reg)

    fun externalCall(s, args) = Tree.CALL(Tree.NAME(Temp.namedlabel s), args)

    fun procEntryExit1(frame,body) = body
    fun procEntryExit2(frame, body) = body @ [
        A.OPER{
            assem = "",
            src = [ZERO,RA,SP] @ calleesaves,
            dst = [], 
            jump=SOME[]
        }
    ]
end