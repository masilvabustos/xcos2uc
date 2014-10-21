
function result = sortEdges(graph, edge_list, director_edge)
    
    paths = getPaths(graph, 'longest_paths_with_terminal_edge', director_edge, edge_list)
    for p = paths
        if graph.node(p(1)).source <> [] | intersect(graph.node(p(1)).convergent_edge(:,1), edge_list) == [] then
            result = lstcat(result, p)
        else
            reduced_paths_list($+1) = p
        end
    end
    
    paths = getPaths(graph, 'longest_paths_with_principal_edge', director_edge, reduced_edge_list)
    for p = paths
        if graph.node(p(1)).sink <> [] then
            // precedence = 0
        else
            // add to reduced
        end
    end
    
    
endfunction
