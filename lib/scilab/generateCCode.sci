
function result = generateTaskCModule(task_name, verbose_graph, objs, fd, conf)
    
    result = []
    
    mfprintf(fd, '#define source_block(x) source_block_##x()\n')
    mfprintf(fd, '#define sink_block(p, r) sink_block_##p(r)\n')
    
    mfprintf(fd, 'struct array_of_2 {_NUMBER_TYPE val[2];};\n')

    for expr = verbose_graph
        if typeof(expr) <> 'function' then
            continue
        end
        generateBlockFunctionCCode(expr.obj_index, objs, fd, conf)
        mfprintf(fd, '\n')
    end
    
    mfprintf(fd, 'void %s()\n{\n', task_name)
    generateTaskCoreCDecls(verbose_graph, objs, fd, conf)
    generateTaskCoreCCode(verbose_graph, objs, fd, conf)
    mfprintf(fd, '}\n\n')
    
    
endfunction

function result = generateBlockFunctionCCode(index, objs, fd, conf)
    
    result = []
    
    block = objs(index)
    name = block.gui
    
    fname = msprintf('__gen%s', name)
    
    if ~ exists(fname) then
        warning(msprintf('%s does not exist.', fname))
    else    
        execstr(msprintf('%s(index, block, fd, conf)', fname))
    end
    
        
endfunction

function result = generateTaskCoreCDecls(verbose_graph, objs, fd, conf)
    
    result = []
    
    registers_set = []
    local_states_set = []
    array_registers_list = []
    a = 1
    input_list = list()
    output_list = list()
    
    for pred = verbose_graph
        select typeof(pred)
        case 'get' then
            registers_set = union([pred.register], registers_set)
            input_list($+1) = pred.obj_index
        case 'put' then
            registers_set = union([pred.register], registers_set)
            output_list($+1) = pred.obj_index
        case 'pull-local' then
            registers_set = union([pred.registers], registers_set)
            local_states_set = union([pred.nodes], local_states_set)
        case 'push-local' then  
            registers_set = union([pred.registers], registers_set)
            local_states_set = union([pred.nodes], local_states_set)
        case 'pull' then  
            registers_set = union([pred.registers], registers_set)        
        case 'push' then  
            registers_set = union([pred.registers], registers_set)        
        case 'function' then  
            registers_set = union([pred.in], registers_set)        
            registers_set = union([pred.out], registers_set)
            if length(pred.out) > 1 then
                array_registers_list($+1) = length(pred.out)
            end

        end
    end
    
    for r = registers_set
        mfprintf(fd, '%sregister _NUMBER_TYPE r%d;\n', conf.indent, r)
    end
    
    for i = 1:length(array_registers_list)
        mfprintf(fd, '%sstruct array_of_%d a%d;\n', conf.indent, ...
            array_registers_list(i), i)
    end
    
    for x = local_states_set
        mfprintf(fd, '%sstatic _NUMBER_TYPE x%d = 0;\n', conf.indent, x)
    end
    
    for i = input_list
        name = objs(i).graphics.id
        if name <> '' then
            mfprintf(fd, '%sextern _NUMBER_TYPE %s();\n', conf.indent, name)
        end
    end
    
     for i = output_list
        name = objs(i).graphics.id
        if name <> '' then
            mfprintf(fd, '%sextern void %s(_NUMBER_TYPE);\n', conf.indent, name)
        end
    end
    
    
    
endfunction

function result = generateTaskCoreCCode(verbose_graph, objs, fd, conf)
    
    result = []
    a = 1
    for pred = verbose_graph
        select typeof(pred)
        case 'get' then
            
            name = objs(pred.obj_index).graphics.id
            
            if name == '' then
                warning('id field not defined')
                name = msprintf('source_block_%d', evstr(objs(pred.obj_index).graphics.exprs))
            end
            
            mfprintf(fd, '%sr%d = %s();\n', conf.indent, pred.register, name)
            
        case 'put' then
            
            name = objs(pred.obj_index).graphics.id
            
            if name == '' then
                warning('id field not defined')
                name = msprintf('sink_block_%d', evstr(objs(pred.obj_index).graphics.exprs))
            end
            
            mfprintf(fd, '%s%s(r%d);\n', conf.indent, name, pred.register)
            
        case 'pull' then
            for i = 1:length(pred.registers)
                r = pred.registers(i)
                n = pred.nodes(i)
                mfprintf(fd, '%sr%d = get_state(%d);\n', conf.indent, pred.register, pred.nodes)
            end
            
            
        case'pull-local' then
            for i = 1:length(pred.registers)
                r = pred.registers(i)
                n = pred.nodes(i)
                mfprintf(fd, '%sr%d = x%d;\n', conf.indent, r, n)
            end
           
            
        case 'push' then
            for i = 1:length(pred.registers)
                r = pred.registers(i)
                n = pred.nodes(i)
                mfprintf(fd, '%sset_state(%d, r%d);\n', conf.indent, n, r)
            end
            
        case 'push-local' then
            for i = 1:length(pred.registers)
                r = pred.registers(i)
                n = pred.nodes(i)
                mfprintf(fd, '%sx%d = r%d;\n', conf.indent, n, r)
            end
            
        case 'function' then
            name = objs(pred.obj_index).gui
            if length(pred.out) > 1 then
                reg_name = 'a'
                reg_index = a
                a = a + 1
            else
                reg_name = 'r'
                reg_index = pred.out(1)
            end
            mfprintf(fd, '%s%s%d = %s_block_%d(', conf.indent, reg_name, reg_index, name, pred.obj_index)
            for i = 1:length(pred.in)-1
                x = pred.in(i)
                mfprintf(fd, 'r%d, ', x(1))
            end
            mfprintf(fd, 'r%d);\n', pred.in($))
            if length(pred.out) > 1 then
                for i = 1:length(pred.out)
                    x = pred.out(i)
                    mfprintf(fd, '%sr%d = a%d.val[%d];\n', conf.indent, x(1), reg_index, i-1)
                end
            end

            
        end
    end
endfunction

function status = __genDLR(index, block, fd, conf)

    status = []

    tf = getTransferFunction(block)
    [fw, fb] = getDirectRealizationCoeff(tf)

    name = msprintf('DLR_block_%d', index)

    generateDirectRealizationCCode(name, fw, fb, fd, conf)
    
endfunction

function trfun = getTransferFunction(block)
    
    if block.gui <> 'DLR' then
        error('getTransferFunction: invalid block (must be DLR)')
    end
    
    num_str = block.graphics.exprs(1)
    den_str = block.graphics.exprs(2)
    
    z = poly(0, 'z')
    num = evstr(num_str)
    den = evstr(den_str)
    
    trfun = num/den
    
endfunction

function [forward_coeff, feedback_coeff] = getDirectRealizationCoeffs(f)
    
    d = coeff(f.den)
    a = zeros(1, length(d))
    
    for i=1:length(a)
        a(i) = d(length(d)-i+1)
    end
    
    c = coeff(f.num)

    n = length(a) - 1
    m = length(c) - 1
    
    b = zeros(1, length(a))
    
    for k = 0:m
        b(n-m+k+1) = c(m-k+1)
    end

    forward_coeff = zeros(1, m+1)
    feedback_coeff = zeros(1, n+1)
    
    for i = 1:length(forward_coeff)
        forward_coeff(i) = b(i)/a(1)
    end
    
    feedback_coeff(1) = 1/a(1)
    for i = 2:length(feedback_coeff)
        feedback_coeff(i) = -a(i)/a(1)
    end

endfunction

function status = generateDirectRealizationCCode(name, forward_coefficients, feedback_coefficients, fd, parameters)

    mfprintf(fd, '#include <string.h>\n')
    mfprintf(fd, 'static __inline__ _NUMBER_TYPE %s(_NUMBER_TYPE e1)\n{\n', name)
    
    mfprintf(fd, '%sstatic _NUMBER_TYPE x[] = {', parameters.indent)
    for i = 1:length(feedback_coefficients)-1
        mfprintf(fd, '0.0, ')
    end
    mfprintf(fd, '0.0};\n') 
    
    mfprintf(fd, '%s_NUMBER_TYPE x0 = %f *e1;\n', ...
        parameters.indent, feedback_coefficients(1))

    mfprintf(fd, '%s_NUMBER_TYPE e2;\n', ...
        parameters.indent)
        
    for i = 2:length(feedback_coefficients)
        mfprintf(fd, '%sx0 += %f * x[%d];\n', ...
            parameters.indent, feedback_coefficients(i), i-1)
    end
        
    mfprintf(fd, '%se2 = %f * x0;\n', ...
        parameters.indent, forward_coefficients(1))
    for i = 2:length(forward_coefficients)
        mfprintf(fd, '%se2 += %f * x[%d];\n', ...
            parameters.indent, forward_coefficients(i), i-1)
        
    end
    
    
    
    mfprintf(fd, '\n%sx[0]=x0; memmove(&x[1], &x[0], sizeof(x)-sizeof(x[0]));\n', ...
        parameters.indent)

    mfprintf(fd, '\n%sreturn e2;\n}\n', parameters.indent)
    

   
    
    status = %t
    
    
endfunction

function result = __genBIGSOM_f(index, block, fd, conf)
    
    result = []
    
    weights = evstr(block.graphics.exprs)
    
    mfprintf(fd, '#define BIGSOM_f_block_%d(', index)
    for i = 1:length(weights)-1
        mfprintf(fd, 'x%d, ', i)
    end
    mfprintf(fd, 'x%d) (', length(weights))
    for i = 1:length(weights)-1
        mfprintf(fd, '%f*(x%d) + ', weights(i), i)
    end
    mfprintf(fd, '%f*(x%d))\n', weights($), length(weights))
    
endfunction

function result = __genSPLIT_f(index, block, fd, conf)
    
    mfprintf(fd, '#define SPLIT_f_block_%d(x) ((struct array_of_2) {(x), (x)})\n', index)

endfunction
