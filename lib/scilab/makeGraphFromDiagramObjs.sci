
// Creates a graph from an object list. Maybe unused

function graph = makeGraphFromDiagramObjs(objs)
     rhs = argn(2);
    
    if rhs == 0 then
        error("Not enought arguments");
    end

    edge_list = getBlocksGraph(objs)
    
    graph = getEmptyStateGraph();
    node_list = list();
    
    for edge = edge_list
        
        if edge.source == %inf then
            // source node
            node_list(edge.sink) = edge.block_data;
        elseif edge.sink == %inf then
            // sink node
            node_list(edge.source) = edge.block_data;
        else
            graph = addEdgeToStateGraph(graph, edge.source, edge.sink, edge.block_data);
            node_list($+1) = tlist(['simple-node']);
        end
    end
    
    graph = setStateGraphNodeList(graph, node_list);
   
endfunction



