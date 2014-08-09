// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at    
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt

function graph = getEmptySignalFlowGraph(n)
    rhs = argn(2);
    if rhs == 0 then
        connmatrix = [];
    else
        connmatrix = zeros(n, n);
    end
    if rhs > 1 then
        warning('Ignoring arguments');
    end
    
    graph = tlist(["SignalFlowGraph", "nodeList", "edgeList", "connectionMatrix"], list(), list(), connmatrix);
    
endfunction


function newGraph = addEdgeToSignalFlowGraph(graph, orig, dest, weight)
    
    if typeof(graph) <> 'SignalFlowGraph' then
        error('addEdgeToSignalFlowGraph: no type');
    end

    newGraph = graph;
    newGraph.edgeList($+1) = weight;
    newGraph.connectionMatrix(dest, orig) = length(newGraph.edgeList); 
      
endfunction
