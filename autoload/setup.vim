" ############################################################################
"
"                               setup Setttings
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

let s:setup_done = 0

function! s:PythonProviders(python) abort
    let l:major = a:python[0]
    let l:minor = a:python[1]
    " let l:patch = l:python[2]

    if os#name('windows')
        let l:candidates = [
                    \ 'c:/tools/python'.l:major,
                    \ 'c:/python'.l:major.l:minor. 'amd64',
                    \ 'c:/python'.l:major.l:minor,
                    \ 'c:/python/'.l:major.l:minor,
                    \ 'c:/python/'.l:major.l:minor. 'amd64',
                    \ 'c:/python/python'.l:major.l:minor,
                    \ 'c:/python_'.l:major.l:minor,
                    \ 'c:/python/python_'.l:major.l:minor,
                    \]
        for l:pydir in l:candidates
            if isdirectory(fnameescape(l:pydir))
                return l:pydir
            endif
        endfor
    elseif executable('python'.l:major.'.'.l:minor)
        return 'python'.l:major.'.'.l:minor
    endif
    return ''
endfunction

function! setup#python() abort
    if s:setup_done
        return
    endif

    let s:python = ['2', '7']

    if s:PythonProviders(s:python) !=# ''
        if exists('g:loaded_python_provider')
            unlet g:loaded_python_provider
        endif
        let g:python_host_prog = s:PythonProviders(s:python)
        if os#name('windows')
            let g:python_host_prog .=  '/python'
        endif
    endif

    for s:minor in ['8', '7', '6', '5', '4']
        let s:python = ['3', s:minor]
        if s:PythonProviders(s:python) !=# ''
            if exists('g:loaded_python3_provider')
                unlet g:loaded_python3_provider
            endif
            let g:python3_host_prog = s:PythonProviders(s:python)
            if os#name('windows')
                let g:python3_host_prog .=  '/python'
            endif
            break
        endif
    endfor

    let s:setup_done = 1

endfunction
