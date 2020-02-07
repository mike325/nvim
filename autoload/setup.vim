" Setup Setttings
" github.com/mike325/.vim

function! s:PythonProviders(python) abort
    let l:major = a:python[0]
    let l:minor = a:python[1]
    " let l:patch = l:python[2]

    let l:pyname = l:major == 2 ? 'python' : 'python3'
    let l:pydll = l:major == 2 ? 'pythondll' : 'pythonthreedll'

    if !has('nvim') && !has(l:pyname) && !exists('+'.l:pydll)
        return ''
    endif

    if os#name('windows')

        let l:pynvim = {
                    \ 'local': vars#home() . '/AppData/Roaming/Python/Python'.l:major.l:minor.'/site-packages/pynvim',
                    \ }

        if exists('*exepath') && (exepath('python' . l:major . '.' . l:minor) || exepath('python' . l:major))
            if exepath('python' . l:major . '.' . l:minor)
                let l:python = 'python' . l:major . '.' . l:minor
                let l:pydir = fnamemodify(exepath('python' . l:major . '.' . l:minor) , ':h')
            else
                let l:python = 'python' . l:major
                let l:pydir = fnamemodify(exepath('python' . l:major), ':h')
            endif

            let l:python = tr(exepath(l:python), "\\", '/')

            if exists('+'.l:pydll)
                execute 'set '.l:pydll . '=python' . l:major . l:minor .'.dll'
            endif

            if !has('nvim')
                return has(l:pyname) ? l:python : ''
            endif

            let l:pydir = tr(l:pydir, "\\", '/')
            let l:pynvim['system'] = l:pydir . '/site-packages/pynvim'
            let l:pynvim['virtual'] = l:pydir . '/Lib/site-packages/pynvim'
            if isdirectory(l:pynvim['virtual']) || isdirectory(l:pynvim['local']) || isdirectory(l:pynvim['system'])
                return l:python
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
                if isdirectory(l:pydir)
                    if !has('nvim')
                        if exists('+'.l:pydll)
                            execute 'set '.l:pydll . '=python' . l:major . l:minor .'.dll'
                        endif
                        return has(l:pyname) ? l:pydir . '/python' : ''
                    elseif has('nvim') && (isdirectory(l:pynvim['local']) || isdirectory(l:pynvim['system']))
                        return l:pydir . '/python'
                    endif
                endif
            endfor
        endif
    elseif !os#name('cygwin')
        let l:pynvim = {
                    \ 'virtual': '',
                    \ 'local': vars#home() . '/.local/lib/python'.l:major.'.'.l:minor.'/site-packages/pynvim',
                    \ 'system': '/usr/lib/python'.l:major.'.'.l:minor.'/site-packages/pynvim'
                    \ }

        if (executable('python'.l:major.'.'.l:minor) || executable('python'.l:major)) &&  (isdirectory(l:pynvim['virtual']) || !has('nvim'))
            if exists('*exepath')
                return executable('python'.l:major.'.'.l:minor) ? exepath('python'.l:major.'.'.l:minor) : exepath('python'.l:major)
            else
                return executable('python'.l:major.'.'.l:minor) ? 'python'.l:major.'.'.l:minor : 'python'.l:major
            endif
        elseif executable('python'.l:major.'.'.l:minor) && (isdirectory(l:pynvim['local']) || isdirectory(l:pynvim['system']) || !has('nvim'))
            return exists('*exepath') ? exepath('python'.l:major.'.'.l:minor) : 'python'.l:major.'.'.l:minor
        elseif executable('python'.l:major) && (isdirectory(l:pynvim['local']) || isdirectory(l:pynvim['system']) || !has('nvim'))
            return exists('*exepath') ? exepath('python'.l:major) : 'python'.l:major
        endif
    endif
    return ''
endfunction

function! setup#python() abort
    if exists('s:setup_done')
        return s:setup_done
    endif

    let s:python = ['2', '7']

    if !empty(s:PythonProviders(s:python))
        if exists('g:loaded_python_provider')
            unlet g:loaded_python_provider
        endif
        let g:python_host_prog = s:PythonProviders(s:python)
    endif

    for s:minor in ['9', '8', '7', '6', '5', '4']
        let s:python = ['3', s:minor]
        if !empty(s:PythonProviders(s:python))
            if exists('g:loaded_python3_provider')
                unlet g:loaded_python3_provider
            endif
            let g:python3_host_prog = s:PythonProviders(s:python)
            break
        endif
    endfor

    let s:setup_done = exists('g:python3_host_prog') || exists('g:python_host_prog') ? 1 : 0

    return s:setup_done
endfunction
