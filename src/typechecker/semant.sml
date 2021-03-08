structure Semant:
	sig val transProg: Absyn.exp -> unit end = 
struct
        structure A = Absyn
        structure TypeTable = RedBlackMapFn (struct type ord_key = Symbol.symbol
					    val compare = (fn(s1, s2) => Int.compare(((fn(s, n) => n) s1),((fn (s, n) => n) s2))) (* use rbmap or hashmap here? *) 
				    end)
	val stack = ref [TypeTable.empty]
	fun transProg (A.VarDec({name: Symbol.symbol,
		     escape: bool ref,
		     typ: (Symbol.symbol * pos) option,
		     init: exp,
		     pos: pos}
		      )) = transProg(init); (* several questions: how do we get types for variable declarations, how do we traverse the tree so all the types are loaded, i.e. at what stage do we check for type mismatch *)  			       
end
