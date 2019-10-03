" Completor settings
" github.com/mike325/.vim

" TODO: Improve completor settings
function! plugins#completor_vim#init(data) abort
    if !exists('g:plugs["completor.vim"]')
        return -1
    endif

    " let g:completor_python_binary = '/path/to/python/with/jedi/installed'
    " let g:completor_racer_binary = '/path/to/racer'
    " let g:completor_clang_binary = '/path/to/clang'
    " let g:completor_gocode_binary = '/path/to/gocode'

    let g:completor_min_chars = 2
    let g:completor_doc_position = 'top'

    let g:completor_blacklist = [
        \ 'log',
        \ 'tagbar',
        \ 'qf',
        \ 'unite',
        \ 'pandoc',
        \ 'infolog',
        \ 'objc',
        \ 'mail',
        \ 'man',
        \ 'tagbar',
        \ 'netrw',
        \ 'unite',
        \ 'denite',
        \ 'GV',
        \ 'git',
        \]

    let g:completor_debug = 1

    if tools#CheckLanguageServer()
        let g:completor_filetype_map = {}

        if executable('ccls') || executable('cquery') || executable('clangd')
            let s:lsp_exe = executable('ccls') ? 'ccls' : 'cquery'
            let g:completor_filetype_map.c = ( executable('ccls') || executable('cquery')) ?
                                           \ {'ft': 'lsp', 'cmd': join(
                                           \    [s:lsp_exe,
                                           \     '--log-file=' . os#tmp(s:lsp_exe . '.log'),
                                           \     '--init={"cacheDirectory":"' . os#cache() . '/' . s:lsp_exe . '"}'], ' ')} :
                                           \ {'ft': 'lsp', 'cmd': 'clangd -index'}

            let g:completor_filetype_map.cpp = g:completor_filetype_map.c
        endif

        if executable('bash-language-server')
            let g:completor_filetype_map.go = {'ft': 'lsp', 'cmd': join(['bash-language-server', 'start'], ' ')}
        endif

        " if executable('pyls') " && !os#name('windows')
        "     let g:completor_filetype_map.python = {'ft': 'lsp', 'cmd': join(['pyls', '--log-file=' . os#tmp('pyls.log')], ' ')}
        " endif

    endif

endfunction
