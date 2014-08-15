
function graph = makeGraphFromDiagram(diagram)
    rhs = argn(2);
    
    if rhs == 0 then
        diagram = scs_m;
    end
    
    if typeof(diagram) <> 'diagram' then
        error("makeGraphFromDiagram: invalid type")
    end
    
    edge_list = list();
    current_node = 0;
    
    for obj = diagram.objs
        
        if typeof(obj) <> 'Link' then
            continue;
        end
        
        current_node = current_node + 1;
        
        // ********* source block ******
        
        block = diagram.objs(obj.from(1)); 
        
        found = %f
        for i = 1:length(edge_list)
            
            edge = edge_list(i);
            
            if edge.weight.gui <> block.gui then
                continue;
            end
                
            if edge.sink == %inf then
                edge_list(i).sink = current_node;
            end
            
            found = %t
            break;
            
        end
        
        if ~found then
            edge_list($+1) = makeStateEdge(%inf, current_node, block);
        end
        
        //******** sink block *********
        block = diagram.objs(obj.to(1)); 
        found = %f;
        for i = 1:length(edge_list)
            
            edge = edge_list(i);
   
            if edge.weight.gui <> block.gui then
                continue;
            end
            
            if edge.source == %inf then
                edge_list(i).source = current_node;
            end 
            
            found = %t;
            break;
            
        end
        
        if ~found then
            edge_list($+1) = makeStateEdge(current_node, %inf, block)
        end 
    end
    
    graph = getEmptyStateGraph();
    node_list = list();
    
    for edge = edge_list
        
        if edge.source == %inf then
            // source node
            node_list(edge.sink) = edge.weight;
        elseif edge.sink == %inf then
            // sink node
            node_list(edge.source) = edge.weight;
        else
            graph = addEdgeToStateGraph(graph, edge.source, edge.sink, edge.weight);
            node_list($+1) = tlist(['simple-node']);
        end
    end
    
    graph = setStateGraphNodeList(graph, node_list);
    
    
endfunction


function edge = makeStateEdge(a, b, weight)
    edge = tlist(['edge', 'source', 'sink', 'weight'], a, b, weight);
endfunction
