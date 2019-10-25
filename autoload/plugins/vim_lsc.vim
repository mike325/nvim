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

    if has('nvim-0.4')
        let g:lsc_hover_popup = 1
    endif

    " ... or set only the commands you want mapped without defaults.
    " Complete default mappings are:
    let g:lsc_auto_map = {
        \ 'GoToDefinition': 'gD',
        \ 'GoToDefinitionSplit': '',
        \ 'FindReferences': 'gr',
        \ 'NextReference': '<C-n>',
        \ 'PreviousReference': '',
        \ 'FindImplementations': 'gI',
        \ 'FindCodeActions': 'ga',
        \ 'Rename': 'gR',
        \ 'ShowHover': 1,
        \ 'DocumentSymbol': 'go',
        \ 'WorkspaceSymbol': 'gS',
        \ 'SignatureHelp': 'gm',
        \ 'Completion': 'completefunc',
        \}

    let g:lsc_server_commands = {}

    if tools#CheckLanguageServer('c')
        let g:lsc_server_commands.c = tools#getLanguageServer('c')
        let g:lsc_server_commands.cpp = g:lsc_server_commands.c
    endif

    if tools#CheckLanguageServer('bash')
        let g:lsc_server_commands.sh = tools#getLanguageServer('sh')
        let g:lsc_server_commands.bash = g:lsc_server_commands.sh
    endif

    if tools#CheckLanguageServer('python') " && !os#name('windows')
        let g:lsc_server_commands.python = tools#getLanguageServer('python')
    endif

endfunction
