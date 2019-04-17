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
        let l:pynvim = {
                    \ 'local': vars#home() . '/AppData/Roaming/Python/Python'.l:major.l:minor.'/site-packages/pynvim',
                    \ }
        if exepath('python' . l:major . '.' . l:minor) || exepath('python' . l:major)
            if exepath('python' . l:major . '.' . l:minor)
                let l:python = 'python' . l:major . '.' . l:minor
                let l:pydir = fnamemodify(exepath('python' . l:major . '.' . l:minor) , ':h')
            else
                let l:python = 'python' . l:major . '.' . l:minor
                let l:pydir = fnamemodify(exepath('python' . l:major), ':h')
            endif
            let l:pydir = tr(l:pydir, "\\", '/')
            let l:pynvim['system'] = l:pydir . '/site-packages/pynvim'
            let l:pynvim['virtual'] = l:pydir . '/Lib/site-packages/pynvim'
            if isdirectory(l:pynvim['virtual']) || isdirectory(l:pynvim['local']) || isdirectory(l:pynvim['system'])
                return tr(exepath(l:python), "\\", '/')
            endif
        else
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
                let l:pynvim['system'] = l:pydir . '/site-packages/pynvim'
                if isdirectory(fnameescape(l:pydir)) && (isdirectory(l:pynvim['local']) || isdirectory(l:pynvim['system']))
                    return l:pydir . '/python'
                endif
            endfor
        endif
    else
        let l:pynvim = {
                    \ 'local': vars#home() . '/.local/lib/python'.l:major.'.'.l:minor.'/site-packages/pynvim',
                    \ 'system': '/usr/lib/python'.l:major.'.'.l:minor.'/site-packages/pynvim',
                    \ 'virtual': ''
                    \ }
        if executable('python'.l:major.'.'.l:minor) && (isdirectory(l:pynvim['local']) || isdirectory(l:pynvim['system']))
            return exepath('python'.l:major.'.'.l:minor)
        elseif executable('python'.l:major) && (isdirectory(l:pynvim['local']) || isdirectory(l:pynvim['system']))
            return exepath('python'.l:major)
        elseif ( executable('python'.l:major.'.'.l:minor) || executable('python'.l:major) ) &&  isdirectory(l:pynvim['virtual'])
            return executable('python'.l:major.'.'.l:minor) ? exepath('python'.l:major.'.'.l:minor) : exepath('python'.l:major)
        endif
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
    endif

    for s:minor in ['8', '7', '6', '5', '4']
        let s:python = ['3', s:minor]
        if s:PythonProviders(s:python) !=# ''
            if exists('g:loaded_python3_provider')
                unlet g:loaded_python3_provider
            endif
            let g:python3_host_prog = s:PythonProviders(s:python)
            break
        endif
    endfor

    let s:setup_done = 1

endfunction
