signature TRANSLATE =
sig
    type level 
    type access (*Not the same as frame access*)
    datatype exp = Ex of Tree.exp
                 | Nx of Tree.stm
                 | Cx of Temp.label * Temp.label  -> Tree.stm

    val outermost: level
    val newLevel: {parent: level, name: Temp.label,formals: bool list} -> level
    val formals: level -> access list
    val allocLocal: level -> bool -> access

    val simpleVar: access * level  -> exp
    val arrayVar (*To be added*)
    val structVar
    val subscriptVar
    val stringVar
    val recordVar
    val whileIR
    val forIR
    (*Maybe need one for every absyn exp?*)
    val binopIR = Tr.binop * exp * exp -> exp
    val relopIR = Tr.relop * exp * exp *  -> exp
    val conditionalIR = exp * exp * exp -> exp

    val unEx: exp -> Tree.exp
    val unNx: exp -> Tree.stm
    val unCx: exp -> (Temp.label * Temp.label -> Temp.stm)
end
    
structure Translate : TRANSLATE = 
struct
    structure Tr = Tree
    structure T = Types
    structure F = MipsFrame
    structure E = ErrorMsg

    type level = unit ref
    type access = level * Frame.access

    fun unEx  (Ex e) = e
      | unEx  (Cx genstm) =
            let val r = Temp.newtemp()
                val t = Temp.newlabel() and f = Temp.newlabel()
            in 
                Tr.ESEQ(seq[Tr.MOVE(Tr.TEMP r, Tr.CONST 1),
                            genstm(t,f),T.LABEL f,
                            Tr.MOVE(Tr.TEMP r, Tr.CONST 0).Tr.LABEL t],
                        Tr.TEMP r)
            end
      | unEx  (Nx s) = Tr.ESEQ(s/Tr.CONST 0)

    fun unNx (Nx n) = n
      | unNx (Ex e) = Tr.EXP(e)
      | unNx (Cx c) = unNx(Ex(unEx(c)))

    fun unCx (Cx c) = c
      | unCx (Ex e) = fn (t, f) => Tr.CJUMP(Tr.EQ, e, Tr.CONST(1), t, f)
      | unCx (Nx n) = (E.error 0 "Cannot unCx an Nx"; fn (t, f) => Tr.EXP(Tr.CONST 0))

    fun binopIR (bop, left, right) = Ex(Tr.BINOP(bop, unEx(left), unEx(right)))

    fun relopIR (rop, left, right, ty) = 
        case (rop, ty) of
            (Tr.EQ, T.STRING) => (*Need external calls for all of these*)
          | (Tr.NE, T.STRING) =>
          | (Tr.LE, T.STRING) =>
          | (Tr.LT, T.STRING) =>
          | (Tr.GE, T.STRING) =>
          | (Tr.GT, T.STRING) =>
          | (r, x) => Cx(fn(t, f) => Tr.CJUMP(r, unEx(left), unEx(right), t, f))

    fun conditionalIR(test, then', else') = 
        let
            val e1 = unCx(test)
            val e2 = unEx(then')
            val e3 = unEx(else')
            val t = Temp.newlabel()
            val f = Temp.newlabel()
            val r = Temp.newtemp()
            val join = Temp.newlabel()
        in
            Ex(Tr.ESEQ(TR.SEQ[
                e1(t, f), Tr.LABEL(t), Tr.MOVE(Tr.TEMP(r), e2), Tr.JUMP(Tr.NAME(join), [join])
                Tr.LABEL(f), Tr.MOVE(Tr.TEMP(r), e3), Tr.JUMP(Tr.NAME(join), [join])
                ]), Tr.TEMP(r)
            )
        end
end