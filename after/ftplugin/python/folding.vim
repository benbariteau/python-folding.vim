func! Foldexpr_python(lnum)
    let current = getline(a:lnum)
    let previous = getline(a:lnum-1)
    let previous2 = getline(a:lnum-2)
    let next = getline(a:lnum+1)
    let next2 = getline(a:lnum+2)

    let blank = '^\s*$'
    let import = '\bimport\b'
    if (current =~ import && previous !~ import && previous2 !~ import)
        return '>1'
    elseif (current =~ import && ((next !~ import) && (next2 !~ import)))
        return '<1'
    elseif (current !~ blank && next =~ blank && next2 =~ blank)
        return '<1'
    elseif current =~ '^class'
        return '>1'
    elseif current =~ '^def'
        return '>1'
    elseif (current =~'\s\+def' && previous !~ '\s\+@')
        return '>2'
    elseif (current =~ '^\s\+@' && previous !~ '\s\+@')
        return '>2'
    else
        return '='
    endif
endfunc

setlocal foldexpr=Foldexpr_python(v:lnum)
setlocal foldmethod=expr
setlocal foldcolumn=3
