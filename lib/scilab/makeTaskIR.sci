
function ir = makeTaskIR(graph, edges, objs)
    
    ir = tlist(['intermediate-representation', 'expr'], list())
    
    for e = edges
        
        for n = graph.edge(e).source
            
                for source = graph.node(n).source
                    expr($+1) = makeExpr(objs(source(1)), source(2))
                end
                
                expr($+1) = makeExpr(objs(graph.edge(e).obj_index))
            end
        end
    end
endfunction
