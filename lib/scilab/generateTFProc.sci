
function status = generateTFProc(name, forward_coefficients, feedback_coefficients, parameters)
    
    fd = parameters.fd

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
