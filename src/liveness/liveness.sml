structure Liveness:
sig
    datatype igraph = IGRAPH of {graph: Graph.graph,
                                tnode: Temp.temp  -> Graph.node,
                                gtemp: Graph.node  -> Temp.temp,
                                moves:  (Graph.node * Graph.node) list}
    val interferenceGraph :Flow.flowgraph ->igraph * (Graph.node  -> Temp.temp list)

    (*val show  : outstream * igraph -> unit*)
end =
struct
    structure A = Assem
    structure F = Flow
    structure G = Graph
    structure T = G.Table
    structure S = Symbol
    structure ILS = IntListSet			

    type liveSet = unit Temp.Table.table * Temp.temp list
    type liveMap = liveSet  T.table

    datatype igraph = IGRAPH of {graph: Graph.graph,
                                tnode: Temp.temp  -> Graph.node,
                                gtemp: Graph.node  -> Temp.temp,
                                moves:  (Graph.node * Graph.node) list}

    fun lookup (tab, x) = case T.look(tab, x) of SOME(y) => y
    							

												
    fun interferenceGraph (F.FGRAPH{control, def, use, ismove}) = let
        fun igraphify() = IGRAPH({graph=G.newGraph(), tnode=(fn(x)=>G.newNode(G.newGraph())),
                            gtemp=(fn(x)=>Temp.newtemp()), moves=[]})
	fun tableEqual(t1, t2) = foldr (fn (x, y) => y andalso (ILS.equal(lookup(t1, x), lookup(t2, x)))) true (G.nodes(control))
			    
        fun livify(fcontrol, fdef, fuse, fismove) = let
	    
            (*initialize in, out*)
            val intable = foldr (fn(x, y)=>T.enter(y, x, ILS.empty)) T.empty (G.nodes(fcontrol))
            val outtable = foldr (fn(x, y)=>T.enter(y, x, ILS.empty)) T.empty (G.nodes(fcontrol))
            fun iter(intab, outab : ILS.set T.table) = let	                
                val fintable = foldr (fn(x, y)=>T.enter(y, x, ILS.union(ILS.fromList(lookup(use, x)), ILS.subtractList(lookup(outab, x), lookup(def, x)))))
				     T.empty (G.nodes(fcontrol))
                val fouttable = foldr (fn(node, y)=>
					  T.enter(y, node, (foldr (fn (suc, res) => ILS.union(lookup(intab, suc), res)) ILS.empty (G.succ(node)))))
				       T.empty (G.nodes(fcontrol))
	    in		            	    						
                if tableEqual(intab, fintable) andalso tableEqual(outab, fouttable) then (fn (x) => ILS.listItems(lookup(outab, x)))  else iter(fintable, fouttable)
            end
        in
	    iter(intable, outtable)
        end							  
							  
    in
        (igraphify(), livify(control, def, use, ismove))
    end
end
