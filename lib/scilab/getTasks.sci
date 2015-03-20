
function edges = getEventDrivenEdges(edge_list)
    
    edges = list()
    
    for i = 1:length(edge_list)
        if edge_list(i).event_source <> 0 then
            edges($+1) = i
        end
    end
endfunction

function task_list = createTasks(edge_list, objs)
    
    if typeof(objs) <> 'list' | typeof(objs) <> 'list' then
        error('createTask: invalid type')
    end
    task_list = list()
    event_driven_edges = getEventDrivenEdges(edge_list)
    
    for i = event_driven_edges
        edge = edge_list(i)
        period = getfield('period', getTimingSpec(objs(edge.event_source)))
        task_list($+1) = makeTask(period, list(edge))
    end
endfunction

function task_list = mergeTasks(from_task_list)
    
    task_list = list()
    working_list = from_task_list
    
    for i = 1:length(working_list)
        if isequal(working_list(i),'deleted') then
            continue
        end
        
        for j = i+1:length(task_list)
            if working_list(i).period == working_list(j).period then
                working_list(j) = 'deleted'
            end
        end
    end
    
    //cleanup
    for e = working_list
        if ~ isequal(e, 'deleted') then
            task_list($+1) = e
        end
    end
    
endfunction

function task = makeTask(period, domain)
    task = tlist(['task', 'period', 'core_edges'], period, domain)
endfunction


function timing_spec = getTimingSpec(event_source)
    
    if typeof(event_source) <> 'Block' then
 
        error(msprintf('getTimingSpec: invalid type, got %s', typeof(event_source)))
        
    end
    
    rhs = argn(2)
    if rhs == 0 then
        timing_spec = tlist(['timing-spec', 'scheme', 'period'], 'none', 0)
        return
    end
    
    period = event_source.model.rpar.objs(2).model.rpar(1)
    timing_spec = tlist(['timing-spec', 'scheme', 'period'], 'clock', period)
    
endfunction

function result = generateTaskCode(graph, order)
    
    for e = order
        edge = graph.edge(e)
        
    end
endfunction
