signature TRANSLATE =
sig
    type level
    type access (*Not the same as frame access*)
    datatype exp = Ex of Tree.exp
                 | Nx of Tree.stm
                 | Cx of Temp.label * Temp.label  -> Tree.stm
                 | FIXME

    val outermost: level
    val newLevel: {parent: level, name: Temp.label,formals: bool list} -> level
    val formals: level -> access list
    val allocLocal: level -> bool -> access

    val arrayVar: exp * exp -> exp
    val simpleVar: access  -> exp
    val stringVar: string -> exp
    (*val structVar
    val subscriptVar
    val recordVar
    val stringIR: string -> exp 
    val letIR*)
    val whileIR: exp * exp * Temp.label -> exp
    (*Maybe need one for every absyn exp?*)
    val binopIR: Absyn.oper * exp * exp -> exp
    val relopIR: Absyn.oper * exp * exp * Types.ty -> exp
    val conditionalIR: exp * exp * exp -> exp
    val nilIR: unit -> exp
    val intIR: int -> exp
    val breakIR: Temp.label -> exp
    val assignIR: exp * exp -> exp
    val letIR: exp list * exp -> exp
    val fundecIR: exp * Temp.label -> exp
    val callIR: Temp.label * exp list -> exp


    val unEx: exp -> Tree.exp
    val unNx: exp -> Tree.stm
    val unCx: exp -> (Temp.label * Temp.label -> Tree.stm)

    val NIL: exp

    val procEntryExit  : {level: level, body: exp}  -> unit

    structure F: FRAME
    val getResult  : unit -> F.frag list
    val fraglist: F.frag list ref
    val resetFragList: unit -> unit
end
    
structure Translate : TRANSLATE = 
struct
    structure TR = Tree
    structure T = Types
    structure F = MipsFrame
    structure E = ErrorMsg
    structure A = Absyn

    type level = {unique: unit ref, frame: F.frame, link: int}
    type access = level * F.access

    val outermost:level = {unique = ref (), frame = F.newFrame({name=Temp.newlabel(), formals=[]}), link = 0}
    val fraglist: F.frag list ref = ref []

    (*fix links*)
    fun newLevel ({parent=parent, name=name, formals=formals}) = {unique=ref (), link = 0, frame=F.newFrame({name=name, formals=formals})}

    fun formals (lvl:level) = 
      let
        fun addLvl([]) = []
          | addLvl(a::b) = (lvl, a)::addLvl(b)
      in 
        addLvl(F.formals(#frame lvl))
      end

    fun allocLocal (lvl:level) (esc) = (lvl, F.allocLocal(#frame lvl)(esc))

    datatype exp = Ex of Tree.exp
                 | Nx of Tree.stm
                 | Cx of Temp.label * Temp.label  -> Tree.stm
                 | FIXME

    val NIL = Ex(TR.CONST 0)

    fun unEx  (Ex e) = e
      | unEx  (Cx genstm) =
            let val r = Temp.newtemp()
                val t = Temp.newlabel() and f = Temp.newlabel()
            in 
                TR.ESEQ(TR.SEQ[TR.MOVE(TR.TEMP r, TR.CONST 1),
                            genstm(t,f),TR.LABEL f,
                            TR.MOVE(TR.TEMP r, TR.CONST 0), TR.LABEL t],
                        TR.TEMP r)
            end
      | unEx  (Nx s) = TR.ESEQ(s, TR.CONST 0)
      | unEx (FIXME) = TR.CONST 0

    fun unNx (Nx n) = n
      | unNx (Ex e) = TR.EXP(e)
      | unNx (Cx c) = unNx(Ex(unEx(Cx c)))
      | unNx (FIXME) = TR.EXP(TR.CONST 0)

    fun unCx (Cx c) = c
      | unCx (Ex e) = (fn (t, f) => TR.CJUMP(TR.EQ, e, TR.CONST(1), t, f))
      | unCx (Nx n) = ((E.error 0 "Cannot unCx an Nx"); (fn (t, f) => TR.EXP(TR.CONST 0)))
      | unCx (FIXME) = unCx(Ex(TR.CONST 0))

    fun simpleVar((lvl, acc):access) = Ex(F.exp(acc)(TR.CONST 0)) (*FIXME fp/static link stuff?*)

    fun aToTbinop(A.PlusOp) = TR.PLUS (*Match is nonexhaustive, which is fine*)
     |  aToTbinop(A.MinusOp) = TR.MINUS
     |  aToTbinop(A.TimesOp) = TR.MUL
     |  aToTbinop(A.DivideOp) = TR.DIV

    fun aToTrelop(A.EqOp) = TR.EQ (*Match is nonexhaustive, which is fine*)
      | aToTrelop(A.NeqOp) = TR.NE
      | aToTrelop(A.GtOp) = TR.GT
      | aToTrelop(A.GeOp) = TR.GE
      | aToTrelop(A.LtOp) = TR.LT
      | aToTrelop(A.LeOp) = TR.LE

    fun binopIR (bop, left, right) = Ex(TR.BINOP(aToTbinop bop, unEx(left), unEx(right)))

    fun relopIR (rop, left, right, ty) = 
        case (rop, ty) of (*Need external calls for all of these*)
            (A.EqOp, T.STRING) => Ex(F.externalCall("stringEqual", [unEx(left), unEx(right)]) )
          | (A.NeqOp, T.STRING) => Ex(TR.BINOP(TR.MINUS, TR.CONST(1), (F.externalCall("stringEqual", [unEx(left), unEx(right)]))))
          | (A.LeOp, T.STRING) => Ex(TR.BINOP(TR.MINUS, F.externalCall("stringLT", [unEx(left), unEx(right)]), (F.externalCall("stringEqual", [unEx(left), unEx(right)]))))
          | (A.LtOp, T.STRING) => Ex(F.externalCall("stringLT", [unEx(left), unEx(right)]))
          | (A.GeOp, T.STRING) => Ex(TR.BINOP(TR.MINUS, TR.CONST(1), (F.externalCall("stringLT", [unEx(left), unEx(right)]))))
          | (A.GtOp, T.STRING) => Ex(TR.BINOP(TR.MINUS, TR.CONST(1), (TR.BINOP(TR.MINUS, F.externalCall("stringLT", [unEx(left), unEx(right)]), (F.externalCall("stringEqual", [unEx(left), unEx(right)]))))))
          | (r, x) => Cx(fn(t, f) => TR.CJUMP(aToTrelop(r), unEx(left), unEx(right), t, f))

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
                e1(t, f), TR.LABEL(t), TR.MOVE(TR.TEMP(r), e2), TR.JUMP(TR.NAME(join), [join]),
                TR.LABEL(f), TR.MOVE(TR.TEMP(r), e3), TR.JUMP(TR.NAME(join), [join]), TR.LABEL(join)
                ], TR.TEMP(r))
            )
        end

    fun stringVar(lit) = let
      val lbl = Temp.newlabel()
      val frg = F.STRING(lbl, lit)
    in
      (fraglist := ((frg)::(!fraglist));
      Ex(TR.NAME(lbl)))
    end

    fun letIR(explist, body) = let
      fun etoslist([]) = []
        | etoslist(a::b) = TR.EXP(unEx(a))::etoslist(b)
    in
      Ex(TR.ESEQ(TR.SEQ(etoslist(explist)), unEx(body)))
    end

    fun fundecIR(body, name) = let
      val b = unEx(body)
    in
      Nx(TR.SEQ[
        TR.LABEL(name),
        TR.MOVE(TR.TEMP(F.RV), b),
        TR.JUMP(TR.TEMP(F.RA), [])
      ])
    end
                                                        (*FIXME static link here*)
    fun callIR(name, explist) = Ex(TR.CALL(TR.NAME(name), (TR.CONST 0)::(map unEx explist)))

    fun nilIR () = Ex(TR.CONST 0)

    fun intIR (n) = Ex(TR.CONST n)

    fun arrayVar (size, init) = Ex(F.externalCall("initArray", [unEx(size), unEx(init)])) 

    (*fun recordVar() = ()

    fun subscriptVar() = ()

    fun fieldVar() = ()*)

    fun whileIR(test, body, done) = 
        let
            val cond = unCx(test)
            val bdy = unNx(body)
            val bodylabel = Temp.newlabel()
            val tst = Temp.newlabel()
        in
            Nx(TR.SEQ([TR.LABEL(tst), cond(bodylabel, done), TR.LABEL(bodylabel), bdy,
             TR.JUMP(TR.NAME(tst), [tst]), TR.LABEL(done)]))
        end

    fun breakIR (label) = Nx(TR.JUMP(TR.NAME(label), [label]))

    fun assignIR (var, ex) = Nx(TR.MOVE(unEx(var), unEx(ex)))

    fun getResult() = !fraglist

    fun resetFragList() = (fraglist := []; ())

    fun procEntryExit({body=body, level=lvl:level}) = fraglist := F.PROC{body=unNx(body), frame= (#frame lvl)}::(!fraglist)
end
