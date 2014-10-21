//
// This file is distributed under CeCill licence.
// Read LICENCE.fr or LICENCE.en distributed with this file for details.
//

function graph = makeSignalFlowGraph(objs)

    regular_link = list()
    
    for l = 1:length(objs)
        if typeof(objs(l)) <> 'Link' then
            continue
        end
        if (objs(l).ct(2) == 1) // Color Type 
            regular_link($+1) = l
        end
    end

    graph = makeGraph(objs, regular_link)
    
endfunction


// Creates an edge list from a diagram objects list.
// An edge is a tuple which elements are: source sink block event_source etc.

function graph = makeGraph(objs, link_list)
    
    graph = tlist(['graph', 'edge', 'node'], list(), list())
    
    [edge_list, node_count] = makeEdgeList(objs, link_list)
    
    node_list = list()
    for i = 1:node_count
        node_list(i) = tlist(['node', 'source_list', 'sink_list', 'convergent_edge', 'divergent_edge'], list(), list(), list(), list())
    end
    
    source_list = list()
    sink_list = list()
    for e = edge_list
        
        if e.source == list() then
            source_list($+1) = e
            continue
        end
        
        if e.sink == list() then
            sink_list($+1) = e
            continue
        end
        
        source = zeros(length(e.source), 2)
        for i = 1:length(e.source)
            source(i, 1:2) = e.source(i)
        end
        
        sink = zeros(length(e.sink), 2)
        for i = 1:length(e.sink)
            sink(i, 1:2) = e.sink(i)
        end
             
        graph.edge($+1) = createBlockTypeEdge(e.obj_index, source, sink)
            
    end

    for e = 1:length(graph.edge)
        for s = graph.edge(e).source'
            node_list(s(1)).divergent_edge($+1) = [e, s(2)]
        end
        
        for s = graph.edge(e).sink'
            node_list(s(1)).convergent_edge($+1) = [e, s(2)]
        end
    end

    for source_edge = source_list
        for source = source_edge.sink
            node_list(source(1)).source_list($+1) = [source_edge.obj_index, source(2)]
            //for e = 1:length(node_list(source(1)).divergent_edge)
             //   node_list(source(1)).divergent_edge(e)(2) = source(2)
            //end
        end
    end

    for sink_edge = sink_list
        for sink = sink_edge.source
            node_list(sink(1)).sink_list($+1) = [sink_edge.obj_index, sink(2)]
            //for e = 1:length(node_list(sink(1)).convergent_edge)
            //    node_list(sink(1)).convergent_edge(e)(2) = sink(2)
            //end
        end
    end
        
    for n = node_list
        divergent_edge = zeros(length(n.divergent_edge), 2)
        for i = 1:length(n.divergent_edge)
            divergent_edge(i,:) = n.divergent_edge(i)
        end
        convergent_edge = zeros(length(n.convergent_edge), 2)
        for i = 1:length(n.convergent_edge)
            convergent_edge(i,:) = n.convergent_edge(i)
        end
        source = zeros(length(n.source_list), 2)
        for i = 1:length(n.source_list)
            source(i,:) = n.source_list(i)
        end
        sink = zeros(length(n.sink_list), 2)
        for i = 1:length(n.sink_list)
            sink(i,:) = n.sink_list(i)
        end
        graph.node($+1) = tlist(['node', 'source', 'sink', 'convergent_edge', 'divergent_edge'], ...
            source, sink, convergent_edge, divergent_edge)
        
    end
        
endfunction


function [edge_list, node_count] = makeEdgeList(objs, link_list)
    
    
    edge_list = list()
    current_node = 0;
    
    for l = link_list
        
        obj = objs(l)      
           
        current_node = current_node + 1;
        
        //mprintf('linking from %d to %d\n', obj.from(1), obj.to(1))
        
        out_port = obj.from
        block_id = out_port(1);
        block = objs(block_id); 

        // Find an edge which has no sink and attach to current node
        // If not found, create a new edge without source connected to current node
        
        found = %f
        for e = 1:length(edge_list)
            
            edge = edge_list(e);
           
            if edge.obj_index <> block_id then
                continue;
            end
            
            edge_list(e).sink = lstcat(edge.sink, [current_node, out_port(2)])
            
            found = %t
            break;
            
        end
        
        if ~found then
            edge_list($+1) = createBlockTypeEdge(block_id, list(), ...
                list([current_node, out_port(2)]))
        end
        
        //******** sink block *********
        
        in_port = obj.to
        block_id = in_port(1);
        block = objs(block_id); 
        found = %f;
        for e = 1:length(edge_list)
            
            edge = edge_list(e);
   
            if edge.obj_index <> block_id then
                continue;
            end
             
            edge_list(e).source = lstcat(edge.source, [current_node, in_port(2)])
            
            found = %t;
            break;
            
        end
        
        if ~found then
            edge_list($+1) = createBlockTypeEdge(block_id, list([current_node, out_port(2)]), list())
        end 
    end
    
    node_count = current_node;
 
    
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

function edge = createBlockTypeEdge(obj_index, source, sink)
    edge = tlist(['block-edge', 'obj_index', 'source', 'sink'], ...
       obj_index, source, sink);
endfunction



function event_source = makeEventSource(block)
    event_source = block.model;
endfunction
