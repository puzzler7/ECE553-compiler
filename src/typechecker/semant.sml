structure Semant:
	sig val transProg: Absyn.exp -> unit end = 
struct
	structure A = Absyn
	
	fun transProg exp = ()
end