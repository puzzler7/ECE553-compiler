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
    val whileIR = exp * exp * exp -> exp
    val letIR
    (*Maybe need one for every absyn exp?*)
    val binopIR = TR.binop * exp * exp -> exp
    val relopIR = TR.relop * exp * exp * Types.ty -> exp
    val conditionalIR = exp * exp * exp -> exp
    val nilIR = unit -> exp
    val intIR = int -> exp
    val stringIR = string -> exp (*to do*)


    val unEx: exp -> Tree.exp
    val unNx: exp -> Tree.stm
    val unCx: exp -> (Temp.label * Temp.label -> Tree.stm)
end
    
structure Translate : TRANSLATE = 
struct
    structure TR = Tree
    structure T = Types
    structure F = MipsFrame
    structure E = ErrorMsg

    type level = {unique=unit ref, frame=F.frame, parent=level, link=int}
    type access = level * Frame.access

    val outermost = {unique=ref (), frame=nil, parent=nil, link=0}

    fun unEx  (Ex e) = e
      | unEx  (Cx genstm) =
            let val r = Temp.newtemp()
                val t = Temp.newlabel() and f = Temp.newlabel()
            in 
                TR.ESEQ(TR.SEQ[TR.MOVE(TR.TEMP r, TR.CONST 1),
                            genstm(t,f),T.LABEL f,
                            TR.MOVE(TR.TEMP r, TR.CONST 0).TR.LABEL t],
                        TR.TEMP r)
            end
      | unEx  (Nx s) = TR.ESEQ(s, TR.CONST 0)

    fun unNx (Nx n) = n
      | unNx (Ex e) = TR.EXP(e)
      | unNx (Cx c) = unNx(Ex(unEx(c)))

    fun unCx (Cx c) = c
      | unCx (Ex e) = fn (t, f) => TR.CJUMP(TR.EQ, e, TR.CONST(1), t, f)
      | unCx (Nx n) = (E.error 0 "Cannot unCx an Nx"; fn (t, f) => TR.EXP(TR.CONST 0))

    fun binopIR (bop, left, right) = Ex(TR.BINOP(bop, unEx(left), unEx(right)))

    fun relopIR (rop, left, right, ty) = 
        case (rop, ty) of
            (TR.EQ, T.STRING) => (*Need external calls for all of these*)
          | (TR.NE, T.STRING) =>
          | (TR.LE, T.STRING) =>
          | (TR.LT, T.STRING) =>
          | (TR.GE, T.STRING) =>
          | (TR.GT, T.STRING) =>
          | (r, x) => Cx(fn(t, f) => TR.CJUMP(r, unEx(left), unEx(right), t, f))

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
            Ex(TR.ESEQ(TR.SEQ[
                e1(t, f), TR.LABEL(t), TR.MOVE(TR.TEMP(r), e2), TR.JUMP(TR.NAME(join), [join])
                TR.LABEL(f), TR.MOVE(TR.TEMP(r), e3), TR.JUMP(TR.NAME(join), [join])
                ]), TR.TEMP(r)
            )
        end

    fun nilIR () = Ex(TR.CONST 0)

    fun intIR (n) = Ex(TR.CONST n)

    fun arrayVar (size, init) = Ex(F.externalCall("initArray", [unEx(size), unEx(init)])) 

    fun whileIR(test, body, done) = 
        let
            cond = unCx(test)
            bdy = unNx(body)
            bodylabel = Temp.newlabel()
            tst = Temp.newlabel()
            (*done = Temp.newlabel()*) (*I think something special might need to happen with breaks - do they get passed in?*)
        in
            Nx(TR.SEQ([TR.LABEL(tst), cond(bodylabel, done), TR.LABEL(bodylabel), TR.EXP(bdy),
             TR.JUMP(TR.NAME(tst), [tst]), TR.LABEL(done)]))
        end
end