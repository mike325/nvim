" vim_lsc Setttings
" github.com/mike325/.vim

function! plugins#vim_lsc#init(data) abort
    " " Use all the defaults (recommended):
    " let g:lsc_auto_map = 1

    " " Apply the defaults with a few overrides:
    " let g:lsc_auto_map = {
    "     \ 'defaults': 1,
    "     \ 'FindReferences': '<leader>r'
    "     \ }

    " " Setting a value to a blank string leaves that command unmapped:
    " let g:lsc_auto_map = {
    "     \ 'defaults': 1,
    "     \ 'FindImplementations': ''
    "     \}

    " ... or set only the commands you want mapped without defaults.
    " Complete default mappings are:
    let g:lsc_auto_map = {
        \ 'defaults': v:true,
        \ 'GoToDefinition': '<c-]>',
        \ 'FindReferences': 'gr',
        \ 'NextReference': '',
        \ 'PreviousReference': '',
        \ 'FindImplementations': 'gD',
        \ 'FindCodeActions': 'ga',
        \ 'Rename': 'gR',
        \ 'DocumentSymbol': '',
        \ 'WorkspaceSymbol': '',
        \ 'SignatureHelp': '',
        \}

    let g:lsc_server_commands = {}

    if tools#CheckLanguageServer('c')
        let g:lsc_server_commands.c = tools#getLanguageServer('c')
        let g:lsc_server_commands.cpp = g:lsc_server_commands.c
        let g:lsc_server_commands.objc = g:lsc_server_commands.c
        let g:lsc_server_commands.objcpp = g:lsc_server_commands.c
    endif

    if tools#CheckLanguageServer('bash')
        let g:lsc_server_commands.sh = tools#getLanguageServer('sh')
        let g:lsc_server_commands.bash = g:lsc_server_commands.sh
    endif

    if tools#CheckLanguageServer('python') " && !os#name('windows')
        let g:lsc_server_commands.python = tools#getLanguageServer('python')
    endif

    if tools#CheckLanguageServer('tex')
        let g:lsc_server_commands.tex = tools#getLanguageServer('tex')
        let g:lsc_server_commands.bib = g:lsc_server_commands.tex
    endif

    if tools#CheckLanguageServer('vim')
        let g:lsc_server_commands.vim = tools#getLanguageServer('vim')
    endif

endfunction
