
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
