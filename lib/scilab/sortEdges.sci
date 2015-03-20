
function result = decideEdgesOrder(graph, edges_vector, director_edge)
    
    
    remaining_edges_vector = edges_vector
    remaining_paths_list = list()
    paths_list = list()
    result = list()
    paths = getPaths(graph, 'longest-paths-with-terminal-edge',...
        director_edge, edges_vector)
  
    for p = paths
        path_edges_vector = getPathEdgesVector(p)

        if graph.node(p(1).node).source <> [] | intersect(graph.node(p(1).node).convergent_edge(:,1), edges_vector) == [] then
            for e = intersect(remaining_edges_vector, path_edges_vector(1:$-1)) // omit last edge, which is the terminal edge
                result($+1) = e
            end
            remaining_edges_vector = setdiff(remaining_edges_vector, path_edges_vector(:))
        end
    end
  
    result($+1) = director_edge
    //remaining_edges_vector = setdiff(remaining_edges_vector, director_edge)
    
   
    paths = getPaths(graph, 'longest-paths-with-principal-edge',...
        director_edge, remaining_edges_vector)

    for p = paths
        path_edges_vector = getPathEdgesVector(p)
        if graph.node(p($).node).sink <> [] | intersect(graph.node(p($).node).divergent_edge(:,1), edges_vector) == [] then
            for e = intersect(remaining_edges_vector, path_edges_vector(2:$)) // omit initial edge, which is the director edge
                result($+1) = e
            end
            remaining_edges_vector = setdiff(remaining_edges_vector, path_edges_vector(:))
        else
            remaining_paths_list($+1) = p
        end
    end
  
    while length(remaining_paths_list) <> 0
        for p = 1:length(remaining_paths_list)
            path = remaining_paths_list(p)
            //disp(path)
            if intersect(remaining_edges_vector, [path(1).edge]) <> [] then
                result($+1) = path(1).edge
                remaining_edges_vector = setdiff(remaining_edges_vector, [path(1).edge])
            end
            remaining_paths_list(p)(1) = null()
        end
        t = list()
        for p = 1:length(remaining_paths_list)
            if remaining_paths_list(p) <> list() then
                t($+1) = remaining_paths_list(p)
            end
        end
        remaining_paths_list = t
    end
    
endfunction

function result = pathsAsVectors(paths_list)
    
    result = list()
    
    for p = paths_list
        path = zeros(2, length(p))
        i = 1
        for e = p
            path(:, i) = e'
            i = i + 1
        end
        result($+1) = path
    end
endfunction

function result = getPathEdgesVector(path)
    
    result = zeros(1, length(path))
    i = 1
    for x = path
        result(i) = x.edge
        i = i + 1
    end
    
endfunction
