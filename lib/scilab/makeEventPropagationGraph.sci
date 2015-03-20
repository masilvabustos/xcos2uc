
//
// This file is distributed under CeCill licence.
// Read LICENCE.fr or LICENCE.en distributed with this file for details.
//

function graph = makeEventPropagationGraph(objs)

    regular_link = list()
    
    for l = 1:length(objs)
        if typeof(objs(l)) <> 'Link' then
            continue
        end
        if (objs(l).ct(2) == -1) // Color Type. Read doc. 
            regular_link($+1) = l
        end
    end

    graph = makeGraph(objs, regular_link)
    
endfunction
