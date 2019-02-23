" ############################################################################
"
"                               languageclient Setttings
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

if !exists('g:plugs["LanguageClient-neovim"]')
    finish
endif

let g:LanguageClient_serverCommands = get(g:, 'LanguageClient_serverCommands', {})
" let g:LanguageClient_loggingFile = os#tmp('languageclient.log')

" let g:LanguageClient_trace           = 'messages'
let g:LanguageClient_selectionUI     = 'Quickfix'
let g:LanguageClient_diagnosticsList = 'Location'

if !executable('fzf')
    let g:LanguageClient_fzfContextMenu = 0
endif

if exists('g:plugs["neomake"]')
    let g:LanguageClient_diagnosticsEnable = 0
endif

augroup LanguageCmds
    autocmd!
augroup end

if executable('ccls') || executable('cquery') || executable('clangd')
    let s:lsp_exe = executable('ccls') ? 'ccls' : 'cquery'
    let g:LanguageClient_serverCommands.c = ( executable('ccls') || executable('cquery')) ?
                                            \ [s:lsp_exe,
                                            \ '--log-file=' . os#tmp(s:lsp_exe . '.log'),
                                            \ '--init={"cacheDirectory":"' . os#cache() . '/' . s:lsp_exe . '", "completion": {"filterAndSort": false}}'] :
                                            \ ['clangd', '-index']

    let g:LanguageClient_serverCommands.cpp = g:LanguageClient_serverCommands.c

    augroup LanguageCmds
        if ( executable('ccls') || executable('cquery') )
            autocmd FileType c,cpp command! -buffer Callers call LanguageClient#cquery_callers()
        endif
        " autocmd FileType c,cpp autocmd CursorHold                                <buffer> call LanguageClient#textDocument_hover()
        " autocmd FileType c,cpp autocmd InsertEnter,CursorMoved,TermOpen,BufLeave <buffer> pclose
        autocmd FileType c,cpp command! -buffer References call LanguageClient#textDocument_references()
        if exists('g:plugs["denite.nvim"]')
            autocmd FileType c,cpp command! -buffer WorkspaceSymbols Denite -highlight-mode-insert=off -highlight-matched-range=off -prompt='WorkSymbols >'     -buffer-name=DeniteBuffer('worksym_') workspaceSymbol
            autocmd FileType c,cpp command! -buffer DocumentSymbols  Denite -highlight-mode-insert=off -highlight-matched-range=off -prompt='DocumentSymbols >' -buffer-name=DeniteBuffer('docsym_')  documentSymbol
        else
            autocmd FileType c,cpp command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
            autocmd FileType c,cpp command! -buffer DocumentSymbols call LanguageClient#textDocument_documentSymbol()
        endif
        autocmd FileType c,cpp command! -nargs=? -buffer RenameSymbol call s:Rename(<q-args>)
        autocmd FileType c,cpp command! -buffer Definition call LanguageClient#textDocument_definition()
        autocmd FileType c,cpp command! -buffer Hover call LanguageClient#textDocument_hover()
        autocmd FileType c,cpp command! -buffer Implementation call LanguageClient#textDocument_implementation()
    augroup end
endif

if executable('ccls')
    let g:LanguageClient_serverCommands.cuda = g:LanguageClient_serverCommands.c
    let g:LanguageClient_serverCommands.objc = g:LanguageClient_serverCommands.c
    augroup LanguageCmds
        autocmd FileType cuda,objc command! -buffer Callers call LanguageClient#cquery_callers()
        " autocmd FileType cuda,objc autocmd CursorHold                                <buffer> call LanguageClient#textDocument_hover()
        " autocmd FileType cuda,objc autocmd InsertEnter,CursorMoved,TermOpen,BufLeave <buffer> pclose
        autocmd FileType cuda,objc command! -buffer References call LanguageClient#textDocument_references()
        if exists('g:plugs["denite.nvim"]')
            autocmd FileType cuda,objc command! -buffer WorkspaceSymbols Denite -highlight-mode-insert=off -highlight-matched-range=off -prompt='WorkSymbols >'     -buffer-name=DeniteBuffer('worksym_') workspaceSymbol
            autocmd FileType cuda,objc command! -buffer DocumentSymbols  Denite -highlight-mode-insert=off -highlight-matched-range=off -prompt='DocumentSymbols >' -buffer-name=DeniteBuffer('docsym_')  documentSymbol
        else
            autocmd FileType cuda,objc command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
            autocmd FileType cuda,objc command! -buffer DocumentSymbols call LanguageClient#textDocument_documentSymbol()
        endif
        autocmd FileType cuda,objc command! -nargs=? -buffer RenameSymbol call s:Rename(<q-args>)
        autocmd FileType cuda,objc command! -buffer Definition call LanguageClient#textDocument_definition()
        autocmd FileType cuda,objc command! -buffer Hover call LanguageClient#textDocument_hover()
        autocmd FileType cuda,objc command! -buffer Implementation call LanguageClient#textDocument_implementation()
    augroup end
endif

" TODO: I had had some probles with pysl in windows, so let's
"       skip it until I can figure it out how to fix this
if executable('pyls') " && !os#name('windows')
    let g:LanguageClient_serverCommands.python = ['pyls', '--log-file=' . os#tmp('pyls.log')]
    augroup LanguageCmds
        " autocmd FileType python autocmd CursorHold                                <buffer> call LanguageClient#textDocument_hover()
        " autocmd FileType python autocmd InsertEnter,CursorMoved,TermOpen,BufLeave <buffer> pclose
        autocmd FileType python command! -buffer References call LanguageClient#textDocument_references()
        autocmd FileType python command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
        autocmd FileType python command! -buffer DocumentSymbols call LanguageClient#textDocument_documentSymbol()
        autocmd FileType python command! -nargs=? -buffer RenameSymbol call s:Rename(<q-args>)
        autocmd FileType python command! -buffer Definition call LanguageClient#textDocument_definition()
        autocmd FileType python command! -buffer Hover call LanguageClient#textDocument_hover()
        autocmd FileType python command! -buffer Implementation call LanguageClient#textDocument_implementation()
    augroup end
endif

function! s:Rename(name)
    if !empty(a:name)
        call LanguageClient#textDocument_rename({'newName': a:name})
    else
        call LanguageClient#textDocument_rename()
    endif
endfunction

if exists('g:plugs["vim-abolish"]')

    " " Rename - rn => rename
    " noremap <leader>rn :call LanguageClient#textDocument_rename()<CR>

    " " Rename - rc => rename camelCase
    noremap <leader>rc :call LanguageClient#textDocument_rename({'newName': Abolish.camelcase(expand('<cword>'))})<CR>

    " " Rename - rs => rename snake_case
    noremap <leader>rs :call LanguageClient#textDocument_rename({'newName': Abolish.snakecase(expand('<cword>'))})<CR>

    " " Rename - ru => rename UPPERCASE
    noremap <leader>ru :call LanguageClient#textDocument_rename({'newName': Abolish.uppercase(expand('<cword>'))})<CR>
endif
