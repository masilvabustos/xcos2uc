
function graph = makeGraphFromDiagram(diagram)
    
    if typeof(diagram) <> 'diagram' then
        error('makeGraphFromDiagram: invalid argument type')
    end
    
    graph = makeGraphFromDiagramObjs(diagram.objs);
    
endfunction



