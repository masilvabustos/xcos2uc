
function edge_list = getBlocksGraph(objs)
    
    
    edge_list = list();
    current_node = 0;
    
    for obj = objs
        
        if typeof(obj) <> 'Link' then
            continue;
        end
        
        block_name = getBlockName(objs(obj.from(1)));
        // Event soruces
        if block_name == 'CLOCK_c' then
            
            found = %f
            block_id = obj.to(1);
            block = objs(block_id);
            event_source = objs(obj.from(1));
            
            for i = 1:length(edge_list)
            
                edge = edge_list(i);
               
                if edge.block_id <> block_id then
                    continue;
                end
                
                edge_list(i).event_source = event_source;
                found = %t  
                break;
                
            end
            
            if ~found then
                
                edge_list($+1) = makeEdgeSpec(block_id, %inf, %inf, block);
                edge_list($).event_source = event_source;
            end
            
            continue;
            
        end
        
        current_node = current_node + 1;
        
        block_id = obj.from(1);
        block = objs(block_id); 

        // ********* source block ******
        
        found = %f
        for i = 1:length(edge_list)
            
            edge = edge_list(i);
           
            if edge.block_id <> block_id then
                continue;
            end
                
            if edge.sink == %inf then
                edge_list(i).sink = current_node;
            end
            
            found = %t
            break;
            
        end
        
        if ~found then
            edge_list($+1) = makeEdgeSpec(block_id, %inf, current_node, block);
        end
        
        //******** sink block *********
        block_id = obj.to(1);
        block = objs(block_id); 
        found = %f;
        for i = 1:length(edge_list)
            
            edge = edge_list(i);
   
            if edge.block_id <> block_id then
                continue;
            end
            
            if edge.source == %inf then
                edge_list(i).source = current_node;
            end 
            
            found = %t;
            break;
            
        end
        
        if ~found then
            edge_list($+1) = makeEdgeSpec(block_id, current_node, %inf, block);
        end 
    end
endfunction

function name = getBlockName(block)
    name = block.gui
endfunction

function edge = makeEdgeSpec(block_id, source, sink, block)
    edge = tlist(['edge', 'block_id', 'source', 'sink', 'block', 'event_source', 'attributes'], block_id, source, sink, block, 'inherited', list());
endfunction

function event_source = makeEventSource(block)
    event_source = block.model;
endfunction
