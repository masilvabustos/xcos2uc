
// This file must be used under the terms of the CeCILL.
// This source file is licensed as described in the file COPYING, which
// you should have received as part of this distribution.  The terms
// are also available at    
// http://www.cecill.info/licences/Licence_CeCILL_V2-en.txt

function status = implDigitalController(sys, method, parameters)
    
    rhs = argn(2);
    
    if rhs == 0 then
        error('implementDigitalController: not enought arguments');
    end
    
    if rhs == 1 then
        method = 'direct';
    end
    
    if rhs <= 2 then
        parameters = getDefaultParamForMethod(method);
    end

    l = list(list('direct', directImpl));
    
    found = %f;
    for e = l
        if e(1) == method then
            status = e(2)(sys, parameters);
            found = %t;
            break;
        end
    end
    
    if ~found then
        error('method not found');
    end

endfunction

function param = getDefaultParamForMethod(method)
    
    l = list(list('direct', tlist(['ImplementationParameters', 'templateSet', 'target'], 'plain_C', 'STM32F4Discovery')));
    param = list();
    for e = l
        if e(1) == method then
            param = e(2);
            break;
        end
    end
    
    if param == list() then
        error('method not found')
    end


endfunction

function status = directImpl(sys, parameters)
    
    disp("implementing");
    status = 0;
    
endfunction
