
function paths = getPaths(graph, criteria, parameter, edge_list)
    rhs = argn(2)
    
    if rhs < 3 then
        error('Not enough arguments')
    elseif rhs == 3 then
        edge_list = 1:length(graph.edge)
    end
    
    paths = list()
    reduced_edge_list = list()
    
    
    
    select criteria
   
    case 'longest-paths-to-node'
        
        convergent_edge = list()
        
        for e = edge_list
            found = %f
            for sink = graph.edge(e).sink(:,1)'
                if sink == parameter then
                    convergent_edge($+1) = e
                    found = %t
                    break
                end
            end
           
            if ~ found then
                reduced_edge_list($+1) = e
            end
        end
        
        for e = convergent_edge
            for source = graph.edge(e).source(:,1)'
                p = getPaths(graph, criteria, source, reduced_edge_list)
                if p == list() then
                    p($+1) = list()
                end 
                for i = 1:length(p)
                    p(i)($+1) = tlist(['node-edge-pair', 'node', 'edge'], source, e)
                end
                paths = lstcat(paths, p)
            end
        end
        
    case 'longest-paths-with-terminal-edge'
        
        for e = edge_list
            if e == parameter then
                continue
            end
            reduced_edge_list($+1) = e
        end
        for source = graph.edge(parameter).source(:,1)'
            p = getPaths(graph, 'longest-paths-to-node', source, reduced_edge_list)
            for i = 1:length(p)
                p(i)($+1) = tlist(['node-edge-pair', 'node', 'edge'], source, parameter)
            end
            paths = lstcat(paths, p)
        end
        
    case 'longest-paths-from-node'
        
        divergent_edge = list()
        
        for e = edge_list
            found = %f
            for source = graph.edge(e).source(:,1)
                if source == parameter then
                    divergent_edge($+1) = e
                    found = %t
                    break
                end
            end
           
            if ~ found then
                reduced_edge_list($+1) = e
            end
        end
        
        for e = divergent_edge
            for sink = graph.edge(e).sink(:,1)'
                p = getPaths(graph, criteria, sink, reduced_edge_list)
                if p == list() then
                    p($+1) = list()
                end 
                for i = 1:length(p)
                    p(i)(0) = tlist(['node-edge-pair', 'node', 'edge'], sink, e)
                end
                paths = lstcat(paths, p)
            end
            
            
        end
        
    case 'longest-paths-with-principal-edge'
        
        for e = edge_list
            if e == parameter then
                continue
            end
            reduced_edge_list($+1) = e
        end
        
        for sink = graph.edge(parameter).sink(:,1)'
            p = getPaths(graph, 'longest-paths-from-node', sink, reduced_edge_list)
            for i = 1:length(p)
                p(i)(0) = tlist(['node-edge-pair', 'node', 'edge'], sink, parameter)
            end
            paths = lstcat(paths, p)
        end
      
    else
        warning("getPaths: unknown criteria, returning empty list")
    end
endfunction
