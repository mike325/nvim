" ############################################################################
"
"                               has Setttings
"
"                                     -`
"                     ...            .o+`
"                  .+++s+   .h`.    `ooo/
"                 `+++%++  .h+++   `+oooo:
"                 +++o+++ .hhs++. `+oooooo:
"                 +s%%so%.hohhoo'  'oooooo+:
"                 `+ooohs+h+sh++`/:  ++oooo+:
"                  hh+o+hoso+h+`/++++.+++++++:
"                   `+h+++h.+ `/++++++++++++++:
"                            `/+++ooooooooooooo/`
"                           ./ooosssso++osssssso+`
"                          .oossssso-````/osssss::`
"                         -osssssso.      :ssss``to.
"                        :osssssss/  Mike  osssl   +
"                       /ossssssss/   8a   +sssslb
"                     `/ossssso+/:-        -:/+ossss'.-
"                    `+sso+:-`                 `.-/+oso:
"                   `++:.  github.com/mike325/.vim  `-/+/
"                   .`                                 `/
"
" ############################################################################

" Check an specific version of python (empty==2)
function! has#python(...) abort

    if !exists('g:python_host_prog') || !exists('g:python3_host_prog')
        call setup#python()
    endif

    let l:version = (a:0 > 0) ? a:1 : 'any'

    if l:version ==# 'any' || l:version ==# ''
        return (has('python') || has('python3'))
    elseif l:version ==# '3'
        return has('python3')
    elseif l:version ==# '2'
        return has('python')
    endif

    return v:false
endfunction

" Check whether or not we have async support
function! has#async() abort
    let l:async = v:false

    if has('nvim') || ( v:version >= 800 && has('patch-8.0.0027'))
        let l:async = v:true
    elseif v:version ==# 704 && has('patch1689')
        let l:async = v:true
    elseif has('job') && has('timers') && has('channel')
        let l:async = v:true
    endif

    return l:async
endfunction

function! has#gui() abort
    return (has('nvim') && exists('g:GuiLoaded')) || (!has('nvim') && has('gui_running'))
endfunction
