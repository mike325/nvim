" arglist Settings
" github.com/mike325/.vim

function! arglist#clear(all) abort
    if a:all
        argdelete *
    else
        for l:filename in argv()
            if ! filereadable(l:filename)
                call execute('argdelete ' . l:filename)
            endif
        endfor
    endif
endfunction

function! arglist#add(filename, clear) abort
    if a:clear
        call arglist#clear(1)
    endif

    let l:files = type(a:filename) != type([]) ?  [a:filename] : a:filename
    if len(l:files) == 0
        let l:files += ['%']
    elseif len(l:files) == 1 && l:files[0] == '*'
        let l:files = []
        for l:buf in range(1, bufnr('$'))
            if bufexists(l:buf)
                let l:bufname = bufname(l:buf)
                if l:bufname != ''
                    let l:files += [l:bufname]
                endif
            endif
        endfor
    endif

    for l:filename in l:files
        let l:buf = bufnr(l:filename)
        if l:buf == -1
            execute "badd " . l:filename
        endif
        execute "argadd " . l:filename
    endfor

    " NOTE: Not all versions of vim have argdedupe
    silent! argdedupe
endfunction

function! arglist#edit(arg) abort
    if argc() == 0
        echomsg "Empty arglist"
        return
    endif

    if a:arg != ''
        let l:idx = 1
        for l:arg in argv()
            if a:arg == l:arg
                execute "argument " . l:idx
                return
            endif
            let l:idx += 1
        endfor
        throw "Invalid argument name"
    endif

    let l:args = []
    let l:idx = 1

    for l:arg in argv()
        let l:args += [string(idx) . '. ' . l:arg]
        let l:idx += 1
    endfor

    let l:choice = inputlist(l:args)
    if l:choice > 0
        execute "argument " . l:choice
    endif
endfunction

"function! arglist#buf_edit(args) abort
"    for l:glob in a:args
"        if filereadable(l:glob)
"            execute 'edit ' . l:glob
"        elseif l:glob =~? '\*'
"            let l:files = glob(l:glob, 0, 1, 0)
"            for l:file in l:files
"                if filereadable(l:file)
"                    execute 'edit ' . l:file
"                endif
"            endfor
"        endif
"    endfor
"endfunction
