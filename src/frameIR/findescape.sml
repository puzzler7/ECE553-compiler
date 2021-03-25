signature FINDESCAPE = 
sig
    type venvType
    type tenvType
    type expty

    val findEscape: Absyn.exp -> Absyn.exp
end

structure FindEscape: FINDESCAPE =
struct
    fun findEscape() = 
end