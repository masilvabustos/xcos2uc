

function result = verbifyGraph(graph, edges)
    
    // !!! ---> Proper nodes not tested!!!
    
    result = list()
    
    proper_nodes_list = getProperNodes(graph, edges)
    proper_nodes = zeros(length(proper_nodes_list))
    i = 1
    for n = proper_nodes_list
        proper_nodes(i) = n
        i = i + 1
    end
    
    r = 1
    for e = edges
        edge = graph.edge(e)
        
        in_list = list()
        len = 0
        for source = edge.source'
            n = source(1)
            node = graph.node(n)
            if length(node.convergent_edge) == 0 then // origin node
                result($+1) = tlist(['get', 'register', 'obj_index', 'port'], r, node.source(1,1), node.source(1,2))
            elseif intersect([n], proper_nodes) == [] then
                result($+1) = tlist(['pull', 'registers', 'nodes'], list(r), list(n))
            else 
                result($+1) = tlist(['pull-local', 'registers', 'nodes'], list(r), list(n)) 
            end
            // 
            in_list($+1) = [r, source(2)]
            len = max([len, source(2)])
            
            r = r + 1
        end
       
        in = zeros(1, len)
        for x = in_list
           in(x(2)) = x(1)
        end
        result($+1) = tlist(['function', 'obj_index', 'in', 'out'], edge.obj_index, in, [])
        current = length(result)
        
        out_list = list()
        len = 0
        for sink = edge.sink'
            n = sink(1)
            node = graph.node(n)
            if length(node.divergent_edge) == 0 then // dest node
                for s = node.sink'
                    result($+1) = tlist(['put', 'register', 'obj_index', 'port'], r, s(1), s(2))
                end
            elseif intersect([n], proper_nodes) == [] then
                result($+1) = tlist(['push', 'registers', 'nodes'], list(r), list(sink(1)))
            else
                result($+1) = tlist(['push-local', 'registers', 'nodes'], list(r), list(sink(1)))
            end
                out_list($+1) = [r, sink(2)]
                len = max([len, sink(2)])
                r = r + 1
        end
        
        out = zeros(1, len)
        for x = out_list
            out(x(2)) = x(1)
        end
        
        result(current).out = out
        
    end
    
endfunction

function result = getProperNodes(graph, edges)
    
    result = list()
    
    if typeof(edges) == 'list' then
        v = zeros(1, length(edges))
        j=1
        for e = edges
           v(1,j) = e
           j = j + 1
        end
        edges = v
    end
    
    for n = 1:length(graph.node)
        node = graph.node(n)
        iedges = union(node.convergent_edge(:,1), node.divergent_edge(:,1))
        
        if setdiff(iedges, edges) == [] then
            result($+1) = n
        end
    end
endfunction
