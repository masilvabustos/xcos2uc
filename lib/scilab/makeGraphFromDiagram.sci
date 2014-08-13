
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
        
        block = diagram.objs(obj.from(1)); // ********* source block ******
        
        found = %f
        for i = 1:length(edge_list)
            
            edge = edge_list(i);
            
            if edge.block.gui <> block.gui then
                continue;
            end
                
            if edge.sink == %inf then
                edge_list(i).sink = current_node;
            end
            
            found = %t
            break;
            
        end
        
        if ~found then
            edge_list($+1) = tlist(['edge', 'source', 'sink', 'block'], %inf, current_node, block);
        end
        
        block = diagram.objs(obj.to(1)); //******** sink block *********
        found = %f;
        for i = 1:length(edge_list)
            
            edge = edge_list(i);
   
            if edge.block.gui <> block.gui then
                continue;
            end
            
            if edge.source == %inf then
                edge_list(i).source = current_node;
            end 
            
            found = %t;
            break;
            
        end
        
        if ~found then
            edge_list($+1) = tlist(['edge', 'source', 'sink', 'block'], current_node, %inf, block);
        end 
    end
    
    for edge = edge_list
        disp([edge.source, edge.sink], edge.block.gui)
    end
    
    graph = getEmptyStateGraph();
    
endfunction
