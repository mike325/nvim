" Has Setttings
" github.com/mike325/.vim

let s:pyversion = {}

" Check an specific version of python (empty==2)
function! has#python(...) abort

    if !exists('g:python_host_prog') || !exists('g:python3_host_prog')
        if ! setup#python()
            return 0
        endif
    endif

    let l:version = (a:0 > 0) ? a:1 : 'any'

    if l:version ==# 'any' || l:version ==# ''
        return (has('python') || has('python3'))
    else
        if empty(s:pyversion)
            if exists('g:python_host_prog')
                let s:pyversion['2'] = matchstr(system(g:python_host_prog . ' --version'), "\\S\\+\\ze\n")
            endif
            if exists('g:python3_host_prog')
                let s:pyversion['3'] = matchstr(system(g:python3_host_prog . ' --version'), "\\S\\+\\ze\n")
            endif
        endif

        let l:version = s:pyversion[a:1]
        let l:components = split(l:version, '\D\+')
        let l:has_version = ''

        for l:i in range(len(a:000))
            if a:000[l:i] > +get(l:components, l:i)
                let l:has_version = 0
                break
            elseif a:000[l:i] < +get(l:components, l:i)
                let l:has_version = 1
                break
            endif
        endfor
        if empty(l:has_version)
            let l:has_version = (a:000[l:i] ==# get(l:components, l:i)) ? 1 : 0
        endif

        if l:has_version
            if l:version[0] ==# '3'
                return has('python3')
            elseif l:version[0] ==# '2'
                return has('python')
            endif
        endif
    endif

    return 0
endfunction

" Check whether or not we have async support
function! has#async() abort
    let l:async = 0

    if has('nvim') || v:version > 800 || ( v:version == 800 && has('patch-8.0.0027') )
        let l:async = 1
    elseif v:version ==# 704 && has('patch-7.4.1689')
        let l:async = 1
    elseif has('job') && has('timers') && has('channel')
        let l:async = 1
    endif

    return l:async
endfunction

function! has#gui() abort
    return ( has('nvim') && ( exists('g:gonvim_running') || exists('g:GuiLoaded')) ) || ( !has('nvim') && has('gui_running') )
endfunction
