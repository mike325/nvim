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

        if tools#CheckLanguageServer('c')
            let g:completor_filetype_map.c = {
                \   'ft': 'lsp',
                \   'cmd': join(tools#getLanguageServer('c'))
                \}
            let g:completor_filetype_map.cpp = g:completor_filetype_map.c
            let g:completor_filetype_map.objc = g:completor_filetype_map.c
            let g:completor_filetype_map.objcpp = g:completor_filetype_map.c
        endif

        if tools#CheckLanguageServer('bash')
            let g:completor_filetype_map.sh = {
                \ 'ft': 'lsp',
                \ 'cmd': join(tools#getLanguageServer('bash'))
                \ }
            let g:completor_filetype_map.bash = g:completor_filetype_map.sh
        endif

        if tools#CheckLanguageServer('python')
            let g:completor_filetype_map.python = {
                \ 'ft': 'lsp',
                \ 'cmd': join(tools#getLanguageServer('python'))
                \ }
        endif

        if tools#CheckLanguageServer('tex')
            let g:completor_filetype_map.tex = {
                \ 'ft': 'lsp',
                \ 'cmd': join(tools#getLanguageServer('tex'))
                \ }
            let g:completor_filetype_map.bib = g:completor_filetype_map.tex
        endif

        if tools#CheckLanguageServer('vim')
            let g:completor_filetype_map.tex = {
                \ 'ft': 'lsp',
                \ 'cmd': join(tools#getLanguageServer('vim'))
                \ }
        endif

        if tools#CheckLanguageServer('Dockerfile')
            let g:completor_filetype_map.Dockerfile = {
                \ 'ft': 'lsp',
                \ 'cmd': join(tools#getLanguageServer('Dockerfile'))
                \ }
            let g:completor_filetype_map.dockerfile = g:completor_filetype_map.Dockerfile
        endif

    endif

endfunction
