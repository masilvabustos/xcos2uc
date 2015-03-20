
function status = generateCodeForTask(name, expr, parameters)
    
    fd = parameters.fd
    status = 0
    
    [global_states, local_states] = getScopedStates(expr)
    static_states = getStaticStates(expr, local_states)
    auto_states = setdiff(local_states, static_states)
    
    mfprintf(fd, 'void %s()\n{\n', name)
    
    generateAutomaticDecls(auto_states, parameters)
    generateRegistersDecl(expr, parameters)
    generateStaticDecls(static_states, parameters)
    
    for e = expr
        generateCodeForExpr(e, parameters)
    end
    
    mfprintf(fd, '}\n\n')
    
endfunction

function status = generateTF(tr_edges, objs, parameters)
    
    status = 0
    
    fd = parameters.fd
    
    for edge = tr_edges
        
        select objs(edge.block_id).gui 
        case 'DLR' then
            
            tf = getTransferFunction(objs(edge.block_id))
            [fw, fb] = getDirectRealizationCoeffs(tf)
            name = msprintf('transfer_procedure_%d', edge.block_id)
            generateTransferFunctionSource(name, fw, fb, parameters)
            
        case 'BIGSOM_f' then
            
            mfprintf(fd, '#define transfer_procedure_%d(', edge.block_id)
            for i = 1:length(edge.source)
                if i > 1 then
                    mfprintf(fd, ', ')
                end
                mfprintf(fd, 'a%d', i)
            end
            mfprintf(fd, ') (0 ')
            
            weights = evstr(objs(edge.block_id).graphics.exprs)
            
            for i = 1:length(edge.source)
                port = edge.in_port(i)(2)
                mfprintf(fd, '+ %f * (a%d) ', weights(port), i)
            end
            
            mfprintf(fd, ')\n')
            
        case 'IN_f' then
            
            mfprintf(fd, '#define source_procedure_%d %s\n', evstr(objs(edge.block_id).graphics.exprs), objs(edge.block_id).graphics.id)
            
        case 'OUT_f' then
            
            mfprintf(fd, '#define sink_procedure_%d(x) %s(x)\n', evstr(objs(edge.block_id).graphics.exprs), objs(edge.block_id).graphics.id)
            
        case 'SPLIT_f' then
            
            disp('oh?')
            mfprintf(fd, '#define block_procedure_%d(x) ', edge.block_id)
            for i = 1:length(edge.sink)
                mfprintf(fd, 'sink: %d ', edge.sink(i))
            end
            
              for i = 1:length(edge.source)
                mfprintf(fd, 'source %d ', edge.source(i))
            end
            
            mfprintf(fd, '\n\n')
            
        else
            error(msprintf('generateTF: unrecognized block: %s', objs(edge.block_id).gui))
            
        end
    end

endfunction

function status = generateStaticDecls(static_states, params)
    status =0
    fd = params.fd
    
    for n = static_states
        mfprintf(fd, '%sstatic _NUMBER_TYPE x%d;%s', params.indent, n, params.trailer)
    end
    
endfunction

function status = generateAutomaticDecls(local_states, params)
    
    status = 0
    
    fd = params.fd
    
    for n = local_states
        mfprintf(fd, '%sregister _NUMBER_TYPE x%d;%s', params.indent, n, params.trailer)
    end
    
endfunction

function status = generateExternDecls(global_states, parameters)
    status = 0
    
    fd = parameters.fd
    
    for s = global_states
        mfprintf(fd, 'extern __STATE _STATE_TYPE x%d;\n', s)
    end
endfunction

function status = generateGetState(global_states, local_states, parameters)
    
    status = 0
    
    fd = parameters.fd
    
    for s = global_states
        mfprintf(fd, '#define get_state_%d() get_global_state(x%d)\n', s, s)
    end
    
    for s = local_states
        mfprintf(fd, '#define get_state_%d() (x%d)\n', s, s)
    end
    
endfunction

function status = generatePutState(global_states, local_states, parameters)
    
    status = 0
    
    fd = parameters.fd
    
    for s = global_states
        mfprintf(fd, '#define put_state_%d(val) put_global_state(x%d, (val))\n', s, s)
    end
    
    for s = local_states
        mfprintf(fd, '#define put_state_%d(val) (x%d = (val))\n', s, s)
    end
    
endfunction

function static_states = getStaticStates(expr, local_states)
    
    static_states = []
    s = []
    
    for e = expr
        select typeof(e)
        case 'put-state' then
            if intersect(local_states, [e.state_no]) == [] then
                continue
            end
            s = cat(1, s, [e.state_no])        
        case 'get-state' then
            if intersect(local_states, [e.state_no]) == [] then
                continue
            end
            if intersect(s, [e.state_no]) == [] then
                static_states = cat(1, static_states, [e.state_no])
            end
            
        end
        
    end
    
endfunction

function [global_states, local_states] = getScopedStates(expr)
    
    global_states = []
    local_states = []
    gets = []
    puts = []
    
    for e = expr
        select (typeof(e))
        case 'get-state' then
            gets = cat(1, gets, [e.state_no])
        case 'put-state' then
            puts = cat(1, puts, [e.state_no])
        end
    end
    
    local_states = intersect(gets, puts)
    
    global_states = setdiff(union(gets, puts), local_states)

endfunction

function register_list = getRegisters(expr)
    
    register_list = list()
    
    for e = expr
        if typeof(e) == 'source-procedure' | typeof(e) == 'get-state' | typeof(e) == 'transfer-procedure' then
            register_list($+1) = e.register
        end
    end
    
endfunction

function status = generateRegistersDecl(expr, parameters)
    
    fd = parameters.fd
    register_list = getRegisters(expr)
    
    
    
    for n = register_list
        mfprintf(fd, '%sregister _NUMBER_TYPE r%d;%s', parameters.indent, ...
            n, parameters.trailer)
    end
    
endfunction

function status = generateCodeForExpr(expr, parameters)
    
    status = %t
    
    fd = parameters.fd
    trailer = parameters.trailer
    indent = parameters.indent
    
    select typeof(expr)
        
    case 'source-procedure' then
 
        mfprintf(fd, '%sr%d = source_procedure_%d();%s', indent, expr.register, expr.port_no, trailer)   
        
    case 'sink-procedure' then
        
            mfprintf(fd, '%ssink_procedure_%d(r%d);%s', indent, expr.port_no, expr.register, trailer)
    
    case 'get-state' then
         
        mfprintf(fd, '%sr%d = get_state_%d();%s', indent, expr.register, expr.state_no, trailer)
            
    case 'put-state' then
        
        mfprintf(fd, '%sput_state_%d(r%d);%s', indent, expr.state_no, expr.register, trailer)
        
    
    case 'transfer-procedure' then
    
        mfprintf(fd, '%sr%d = transfer_procedure_%d(r%d', indent, expr.register, expr.block_no, expr.arguments(1))
        
        for i = 2:length(expr.arguments)
            mfprintf(fd, ", r%d", expr.arguments(i))
        end
        mfprintf(fd, ");%s", trailer)
        
    else 
        error("generateCodeForExpr: invalid type")
    end
    
endfunction

function [expr, new_context] = getExpr(data_flow, objs, context)
    
    expr = list()
    new_context = context
        
    if typeof(data_flow) <> 'data-flow' then
        error('getExpr: invalid type')
    end
    
    if data_flow.edge.source == list() then
        register = new_context.first_unused_register
        expr($+1) = tlist(['source-procedure', 'register', 'port_no'], register, evstr(objs(data_flow.edge.block_id).graphics.exprs))
        expr($+1) = tlist(['put-state', 'state_no', 'register', 'index'], data_flow.edge.sink(1), register, 0)
        new_context.first_unused_register = register + 1
        return
    end
    
    if data_flow.edge.sink == list() then
        register = new_context.first_unused_register
        expr($+1) = tlist(['get-state', 'register', 'state_no'], register, data_flow.edge.source(1))
        expr($+1) = tlist(['sink-procedure', 'port_no', 'register'], evstr(objs(data_flow.edge.block_id).graphics.exprs), register)
         new_context.first_unused_register = register + 1
        return
    end
    
    for flow = data_flow.pull_flow
        [e, new_context] = getExpr(flow, objs, new_context)
        expr = lstcat(expr, e)
    end
    
    args = list()
    
    for n = data_flow.edge.source
        register = new_context.first_unused_register
        expr($+1) = tlist(['get-state', 'register', 'state_no'], register, n)
        args($+1) = register
        new_context.first_unused_register = register + 1
    end
    
    
    register = new_context.first_unused_register
    expr($+1) = tlist(['transfer-procedure', 'register', 'block_no', 'arguments'], register, data_flow.edge.block_id, args)
    result_register = register
    new_context.first_unused_register = register + 1
    
    for i = 1:length(data_flow.edge.sink)
        state_no = data_flow.edge.sink(i)
        expr($+1) = tlist(['put-state', 'state_no', 'register', 'index'], state_no, result_register, i-1)
    end
    
    for flow = data_flow.push_flow
        [e, new_context] = getExpr(flow, objs, new_context)
        expr = lstcat(expr, e)
    end

endfunction

function node = makeTreeNode(edge, pull_tree, push_tree)
    node = tlist(['node', 'edge', 'pull_tree', 'push_tree'], edge, pull_tree, push_tree)
endfunction

function path = makePullGraph(edge, graph_list)
    
    rhs = argn(2)
    if rhs == 0 then
        path = tlist(['empty-pull-graph'])
        return
    end
    path = tlist(['pull-graph', 'edge', 'graph_list'], edge, graph_list)
endfunction

function result = decideDataFlowHints(criteria, edge_list, start_edge)
    
    result = list()
    
    select criteria
        
    case 'pull-from-source' then
        
        result = tlist([criteria, 'edges'], list())
        for node = start_edge.source
            paths = getPaths('inwards', node, edge_list)
            for p = paths
                if edge_list(p(1)).source == list() then
                    for e = p
                        if edge_list(e).data_flow_hint == '' then
                            result.edges($+1) = e
                        end
                    end
                end
            end
        end
        
    case 'push-to-sink' then
        
        result = tlist([criteria, 'edges'], list())
        for node = start_edge.sink
            paths = getPaths('outwards', node, edge_list)
            for p = paths
                if edge_list(p($)).sink == list() then
                    for e = p
                        if edge_list(e).data_flow_hint == '' then
                            result.edges($+1) = e
                        end
                    end
                end
            end
        end
        
    
    case 'pull-in-preorder' then
        
        result = tlist([criteria, 'edges'], list())
        paths = getPaths(edge_list, start_edge, 'inwards')
        preorder_edges = getSubGraphEdges(subgraph)
        for i = preorder_edges
            if edge_list(i).data_flow_hint == '' then
                result.edges($+1) = i
            end
        end
        
        return
        
    case 'push-in-postorder' then
        
        result = tlist([criteria, 'edges'], list())
        postorder_edges = getXorderEdges(edge_list, start_edge, 'post')
        for i = postorder_edges
            if edge_list(i).data_flow_hint == '' then
                result.edges($+1) = i
            end
        end
        
        return
        
    case 'push-preferred' then
        
        result = tlist([criteria, 'pull_edges', 'push_edges'], list(), list())
        result.push_edges = getfield('edges', decideDataFlowHints('push-to-sink', ...
            edge_list, start_edge))
        result.pull_edges = getfield('edges', decideDataFlowHints('pull-from-source', ...
            edge_list, start_edge))

       return
       
    else
        error('decideDataFlowHints: invalid criteria')
    end
    
endfunction

function edge_list = applyDataFlowHints(from_edge_list, result)
    
    edge_list = from_edge_list
    
    select typeof(result)
        
    case 'push-preferred' then
        
        for i = result.push_edges
            edge_list(i).data_flow_hint = 'push'
        end
        
        for i = result.pull_edges
            if edge_list(i).data_flow_hint == '' then
                edge_list(i).data_flow_hint = 'pull'
            end
        end
        
        return
        
    else
        error('applyDataFlowHints: invalid type')
    end
    
    edge_list = list()
    error('applyDataFlowHints: unreachable')
    
endfunction
function data_flow = getDataFlow(edge_list, start_edge)
    
    data_flow = tlist(['data-flow', 'edge', 'pull_flow', 'push_flow'], start_edge, ...
        list(), list())
        
    for node = start_edge.source
        for edge = edge_list
            
            if edge.data_flow_hint <> 'pull' then
                continue
            end
            
            found = %f
            for sink = edge.sink
                if sink == node then
                    data_flow.pull_flow($+1) = getDataFlow(edge_list, edge)
                    found = %t
                    break
                end
            end
            
            if found then
                break
            end
            
        end
    end
    
    for node = start_edge.sink
        for edge = edge_list
            
            if edge.data_flow_hint <> 'push' then
                continue
            end
            
            for source = edge.source
                if source == node then
                    data_flow.push_flow($+1) = getDataFlow(edge_list, edge)
                end
            end
        end
    end
    
endfunction
function result = getPullGraph(edge_list, begin)
    
    result = [] 
    
    disp(typeof(begin))
    
    if typeof(begin) == 'constant' then
        
        for edge = edge_list
            
            if edge.timing_spec.scheme <> 'pull' then
                continue
            end
            
            disp(edge.sink)
            disp(begin)
            for sink = edge.sink
                if sink == begin then
                    disp('found')
                    result = makePullGraph(edge, getPullGraph(edge_list, edge))
                    break
                end
            end
        end
        
    elseif typeof(begin) == 'edge' then
        
        result = list()
        
        for node = begin.source
            result($+1) = getPullGraph(edge_list, node)
        end
    else
        error("getPullTree: invalid type")
        
    end
    
    
    
endfunction 

function tree = getPushTree(edge_list, start_node)
    
    tree = list()
    
    for edge = edge_list
        
        if edge.timing_spec.scheme <> 'push' then
            continue
        end
        
        for source = edge.source
            if source <> start_node then
                continue
            end
            tree($+1) = tlist(['node', 'edge', 'pull_tree', 'push_tree'], edge, list(), list())
        end
    end
    
    for i = 1:length(tree)
        for sink = tree(i).edge.sink
            tree(i).push_tree = getPushTree(edge_list, sink)
        end
        
        for source = tree(i).edge.source
            if source == start_node then
                continue
            end
            tree(i).pull_tree = getPullTree(edge_list, source)
        end
    end
   
endfunction 

function xorder_edges = getXorderEdges(edge_list, begin, x)
    
    select x
    case 'pre' then
        direction = list('sink', 'source')
    case 'post' then
        direction = list('source', 'sink')
    else
        error('getXorderEdges: invalid x')
    end
    
    xorder_edges = list()
      
    select typeof(begin)
    
    case 'constant' then // A node
    
        for i = 1:length(edge_list)
            for node = edge_list(i)(direction(1))
                if node == begin then
                    xorder_edges($+1) = i
                end
            end
        end
     
    case 'edge' then
         
         for node = begin(direction(2))
             xorder_edges = lstcat(xorder_edges, getXorderEdges(edge_list, node, x)) 
         end
     
    else
        error('getPreorderEdges: invalid type')
    end

endfunction

function paths_list = getPaths(direction, node, edge_list)
    
    paths_list = list()
    
    select direction
        
    case 'inwards' then 
        
        for e = 1:length(edge_list)
            for sink = edge_list(e).sink
                if sink == node then
                    mprintf('get_Paaths adding edge %d (block_id %d) node %d\n ', e, edge_list(e).block_id, node)
                    paths = list()
                    reduced_edge_list = edge_list
                    reduced_edge_list(e).sink = list()
                    for source = edge_list(e).source
                        paths = lstcat(paths, getPaths(direction, source, reduced_edge_list))
                    end
                    
                    if paths == list() then
                        paths = list(list())
                    end
                    
                    for p = 1:length(paths)
                        paths(p)($+1) = e
                    end
                    
                    paths_list = lstcat(paths_list, paths)
                        
                        for p = paths_list
                            mprintf('path: ')
                            for e = p
                                mprintf('%d ', e)
                            end
                            mprintf('\n')
                        end
                        mprintf('\n')
                        
                    
                end
            end
        end
        
        
        
    case 'outwards' then
        
        for e = 1:length(edge_list)
            for source = edge_list(e).source
                if source == node then
                    mprintf('get_Paaths (outwards) adding edge %d (block_id %d) node %d\n ', e, edge_list(e).block_id, node)
                    paths = list()
                    reduced_edge_list = edge_list
                    reduced_edge_list(e).source = list()
                    
                    for sink = edge_list(e).sink
                        paths = lstcat(paths, getPaths(direction, sink, reduced_edge_list))
                    end
                    
                    if paths == list() then
                        paths = list(list())
                    end
                    
                    for p = 1:length(paths)
                        paths(p)(0) = e
                    end
                    
                    paths_list = lstcat(paths_list, paths)
                    
                    for p = paths_list
                            mprintf('path: ')
                            for e = p
                                mprintf('%d ', e)
                            end
                            mprintf('\n')
                        end
                        mprintf('\n')
                        
                    
                end
            end
        end
        
    else
        error('getPaths: invalid direction')
    end

endfunction
function result = getEdges(criteria, edge_list, relative_to)
    
    result = list();
    
    select typeof(relative_to)
    case 'constant' then
        realtive_to_index = relative_to
        relative_to_edge = edge_list(relative_to)
    case 'edge' then
        relative_to_edge = relative_to
        for i = 1:length(edge_list)
            if edge_list(i).block_id == relative_to.block_id then
                relative_to_index = i
                break
            end
        end
    else
        error('getEdges: invalid type for realtive_to')
    end
    
    select criteria
        
    case 'inwards' then
        
        collect = list()
        for e = 1:lenght(edge_list)
            for sink = edge_list(e).sink
                for node = relative_to_edge.source
                    if sink == node then
                        collect($+1) = e
                    end
                end
            end
        end
        
        result = lstcat(result, collect)
        new_edge_list = edge_list
        new_edge_list(relative_to_index) = null()
        for e = collect
           result = lstcat(result, getEdges(criteria, new_edge_list, e))
        end
        
        return
        
    case 'outwards' then
    
        collect = list()
        for e = 1:lenght(edge_list)
            for source = edge_list(e).source
                for node = relative_to_edge.sink
                    if source == node then
                        collect($+1) = e
                    end
                end
            end
        end
        
        result = lstcat(result, collect)
        new_edge_list = edge_list
        new_edge_list(relative_to_index) = null()
        for e = collect
           result = lstcat(result, getEdges(criteria, new_edge_list, e))
        end
        
        return
        
    else
        
        error('getPaths: invalid direction')
 
    end
    
    
    
endfunction

function edge_list = getSubGraphEdges(sub_graph)
    
    edge_list = list()
    
    edge_list($+1) = sub_graph.edge
    
    for p = sub_graph.paths_list
        edge_list = lstcat(edge_list, getSubGraphEdges(p))
    end
    
endfunction
