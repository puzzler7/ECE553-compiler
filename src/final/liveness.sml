structure Liveness:
sig
    datatype igraph = IGRAPH of {graph: Graph.graph,
                                tnode: Temp.temp  -> Graph.node,
                                gtemp: Graph.node  -> Temp.temp,
                                moves:  (Graph.node * Graph.node) list}
    val interferenceGraph :Flow.flowgraph ->igraph * (Graph.node  -> Temp.temp list)

    val show  : TextIO.outstream * igraph -> unit
end =
struct
    structure A = Assem
    structure F = Flow
    structure G = Graph
    structure T = G.Table
    structure S = Symbol
    structure ILS = IntListSet			

    type liveSet = unit Temp.Table.table * Temp.temp list
    type liveMap = liveSet T.table

    datatype igraph = IGRAPH of {graph: Graph.graph,
                                tnode: Temp.temp  -> Graph.node,
                                gtemp: Graph.node  -> Temp.temp,
                                moves:  (Graph.node * Graph.node) list}

    fun show (out, IGRAPH{graph=gr, tnode=tn, gtemp=gt, moves=mv}) = let
      fun pr(s) = TextIO.output(out, s)
      fun prNode(n) = pr(Temp.makestring(gt(n)))
      fun prNodeList([]) = pr("\n")
        | prNodeList(a::b) = (prNode(a); pr(", "); prNodeList(b))
      fun prGraphNodes([]) = ()
        | prGraphNodes(a::b) = (prNode(a); pr(": "); prNodeList(G.adj(a)); prGraphNodes(b))
    in
      prGraphNodes(G.nodes(gr))
    end

    fun lookup (tab, x) = case T.look(tab, x) of SOME(y) => y
												
    fun interferenceGraph (F.FGRAPH{control, def, use, ismove}) = let
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
                if tableEqual(intab, fintable) andalso tableEqual(outab, fouttable) then (fn (x) => ILS.listItems(lookup(outab, x)) : Temp.temp list)  else iter(fintable, fouttable)
            end
        in
	    iter(intable, outtable)
        end

        val liveFn = livify(control, def, use, ismove)		

        fun igraphify() = let
            val nodelist: G.node list ref = ref []
            val templist: Temp.temp list ref = ref []

            fun seen(a, []) = false
              | seen(a, b::c) = if a = b then true else seen(a, c)

            fun addTemps(g, SOME([])) = g
              | addTemps(g, NONE) = g
              | addTemps(g, SOME(a::b)) = if seen(a, !templist) then addTemps(g, SOME(b)) 
                  else (nodelist := G.newNode(g)::(!nodelist); templist := a::(!templist); addTemps(g, SOME(b)))
              
            fun addNodes (g, []) = g
              | addNodes (g, a::b) = (addTemps(g, T.look(def, a)); addTemps(g, T.look(use, a)); addNodes(g, b))
            val retgraph = addNodes(G.newGraph(), G.nodes(control))

            fun temp2Node(temp) = let
                fun thelp(temp, [], cnt) = (ErrorMsg.error 0 "temp not found, cry"; G.newNode(control))
                  | thelp(temp, a::b, cnt) = if temp = a then List.nth(!nodelist, cnt) 
                                                else thelp(temp, b, cnt+1)
            in
                thelp(temp, !templist, 0)
            end

            fun node2Temp(node) = let
                fun nhelp(node, [], cnt) = (ErrorMsg.error 0 "node not found, cry"; Temp.newtemp())
                  | nhelp(node: G.node, a::b : G.node list, cnt) = if G.eq(node,a) then List.nth(!templist, cnt) 
                                                else nhelp(node, b, cnt+1)
            in
                nhelp(node, !nodelist, 0)
            end

            (*Iterate over nodes
            make edge for every pair in liveness
            add to moves list if move
            *)
            fun edgify(g) = let
                val moveslist = ref []

                fun addEdges(g, [], ismove) = g
                  | addEdges(g, a::b, ismove) = let
                      fun firstEdge(g, first, []) = g
                        | firstEdge(g, first, second::lst) = ((case ismove of 
                                                    SOME(true) => (moveslist:=(first, second)::(second, first)::(!moveslist);()) 
                                                      | _ => ());
                                                              G.rm_edge_safe{from=first, to=second};
                                                              G.rm_edge_safe{from=second, to=first};
                                                              G.mk_edge{from=first, to=second};
                                                              firstEdge(g, first, lst))
                  in
                      addEdges(firstEdge(g, a, b), b, ismove)
                  end

                fun iterCtrlNodes(g, []) = g
                  | iterCtrlNodes(g, a::b) = iterCtrlNodes(addEdges(g, (map (fn x => temp2Node(x)) (liveFn a)), T.look(ismove, a)), b)
            in
                (iterCtrlNodes(g, G.nodes(control)), !moveslist)
            end

            val ret = edgify(retgraph)
        in
            IGRAPH{graph=(#1 ret), tnode=temp2Node, gtemp=node2Temp, moves=(#2 ret)}
        end  
							  
    in
        (igraphify(), liveFn)
    end
end
