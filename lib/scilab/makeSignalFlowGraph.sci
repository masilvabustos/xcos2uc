
// Creates an edge list from a diagram objects list.
// An edge is a tuple which elements are: source sink block event_source etc.
 
function edge_list = makeSignalFlowGraph(objs)
    
    
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
                
                edge_list(i).event_source = obj.from(1);
                found = %t  
                break;
                
            end
            
            if ~found then
                
                edge_list($+1) = createEdge(list(), list(), block_id, list(), list());
                edge_list($).timing_spec = getTimingSpec(event_source);
            end
            
            continue;
            
        end
        
        current_node = current_node + 1;
        
        //mprintf('linking from %d to %d\n', obj.from(1), obj.to(1))
        
        out_port = obj.from
        block_id = out_port(1);
        block = objs(block_id); 

        // Find an edge which has no sink and attach to current node
        // If not found, create a new edge without source connected to current node
        
        found = %f
        for i = 1:length(edge_list)
            
            edge = edge_list(i);
           
            if edge_list(i).block_id <> block_id then
                continue;
            end
            
            edge_list(i).sink = lstcat(edge_list(i).sink, current_node)
            edge_list(i).out_port = lstcat(edge_list(i).out_port, out_port)
            
            found = %t
            break;
            
        end
        
        if ~found then
            edge_list($+1) = createEdge(list(), list(current_node), block_id, list(), list(out_port));
        end
        
        //******** sink block *********
        
        in_port = obj.to
        block_id = in_port(1);
        block = objs(block_id); 
        found = %f;
        for i = 1:length(edge_list)
            
            edge = edge_list(i);
   
            if edge.block_id <> block_id then
                continue;
            end
             
            edge_list(i).source = lstcat(edge_list(i).source, current_node)
            edge_list(i).in_port = lstcat(edge_list(i).in_port, in_port)
            
            found = %t;
            break;
            
        end
        
        if ~found then
            edge_list($+1) = createEdge(list(current_node), list(), block_id, list(in_port), list());
        end 
    end
    
    //edge_list = mergeEdges(edge_list) not used, implicitly merged
    
endfunction

function edge_list = mergeEdges(from_edge_list)
    
    if typeof(from_edge_list) <> 'list' then
        error('megeEdges: invalid type')
    end
    
    edge_list = from_edge_list
    
    for i = 1:length(edge_list)
        
        if isequal(edge_list(i), 'deleted') then
            continue
        end
        
        for j = i+1:length(edge_list)
            
            if isequal(edge_list(j), 'deleted') then
                continue
            end
            
            if edge_list(j).block_id <> edge_list(i).block_id then
                continue
            end
            
            edge_list(i).source = lstcat(edge_list(i).source, from_edge_list(j).source)
            edge_list(i).sink = lstcat(edge_list(i).sink, from_edge_list(j).sink)
            edge_list(i).in_port = lstcat(edge_list(i).in_port, from_edge_list(j).in_port)
            edge_list(i).out_port = lstcat(edge_list(i).out_port, from_edge_list(j).out_port)
            
            edge_list(j) = 'deleted'
            
        end
    end
    
    for i = 1:length(edge_list)
        if isequal(edge_list(i), 'deleted') then
            edge_list(i) = null()
        end
    end
    
endfunction

function [transfer_edges, inout_edges] = separateInOutEdges(edge_list)
    
    inout_edges = list()
    transfer_edges = list()
    
    for edge = edge_list
        if edge.source == list() | edge.sink == list()  then
            inout_edges($+1) = edge
        else
            transfer_edges($+1) = edge
        end
    end
endfunction


function name = getBlockName(block)
    name = block.gui
endfunction

function edge = createEdge(source, sink, block_id, in_port, out_port)
    edge = tlist(['edge', 'block_id', 'source', 'sink', 'in_port', 'out_port', 'data_flow_hint', 'event_source', 'attributes'], block_id, source, sink, in_port, out_port, '', 0,  list());
endfunction



function event_source = makeEventSource(block)
    event_source = block.model;
endfunction
