
function expr = makeEdgeExpr(edge, objs)
    
    block = objs(edge.obj_index)
    
    select block.gui
    case 'DLR'  
        expr($+1) = tlist(['defun', 'name', 'expr'], 'transfer_function_', edge.block.graphics.exprs, 0)
        expr($+1) = tlist(['', ])
    case 'BIGSOM_f'
        expr = tlist(['linear-combination', 'map', 'coeff'], edge.in_ports, edge.block.graphics.exprs)
    case 'IN_f'
        expr = tlist(['input-variable', 'no'], block.graphics.exprs)
    case 'OUT_f'
        expr = tlist(['output-variable', 'no'], block.graphics.exprs)
    else
        expr = e.expr.block.gui
    end
endfunction
