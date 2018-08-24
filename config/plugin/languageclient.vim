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

" let g:LanguageClient_trace           = 'messages'
let g:LanguageClient_selectionUI     = 'Quickfix'
let g:LanguageClient_diagnosticsList = 'Location'

if !executable('fzf')
    let g:LanguageClient_fzfContextMenu = 0
endif

if exists('g:plugs["neomake"]')
    let g:LanguageClient_diagnosticsEnable = 0
endif

let s:log_dir = '/tmp'
if WINDOWS()
    let s:log_dir = 'c:/temp'
endif

if executable('cquery')
    let g:LanguageClient_serverCommands.c = ['cquery', '--log-file=' . s:log_dir . '/cq.log', '--init={"cacheDirectory":"' . g:home . '/.cache/cquery", "completion": {"filterAndSort": false}}']
    let g:LanguageClient_serverCommands.cpp = g:LanguageClient_serverCommands.c
elseif executable('clangd')
    let g:LanguageClient_serverCommands.c = ['clangd']
    let g:LanguageClient_serverCommands.cpp = g:LanguageClient_serverCommands.c
endif

if executable('pyls')
    let g:LanguageClient_serverCommands.python = ['pyls', '--log-file=' . s:log_dir . '/pyls.log']
endif

if executable('pyls') || ( executable('cquery') || executable('clangd') )
    augroup LanguageCmds
        autocmd!
        if executable('cquery')
            autocmd FileType c,cpp command! -buffer Callers call LanguageClient#cquery_callers()
            autocmd FileType c,cpp command! -buffer References call LanguageClient#textDocument_references()
            autocmd FileType c,cpp command! -buffer Definition call LanguageClient#textDocument_definition()
            autocmd FileType c,cpp command! -buffer Implementation call LanguageClient#textDocument_implementation()
            autocmd FileType c,cpp command! -buffer Hover call LanguageClient#textDocument_hover()
            autocmd FileType c,cpp command! -buffer RenameSymbol call LanguageClient#textDocument_rename()
        elseif executable('clangd')
            autocmd FileType c,cpp command! -buffer References call LanguageClient#textDocument_references()
            autocmd FileType c,cpp command! -buffer Definition call LanguageClient#textDocument_definition()
            autocmd FileType c,cpp command! -buffer Implementation call LanguageClient#textDocument_implementation()
            autocmd FileType c,cpp command! -buffer Hover call LanguageClient#textDocument_hover()
            autocmd FileType c,cpp command! -buffer RenameSymbol call LanguageClient#textDocument_rename()
        endif
        if executable('pyls')
            autocmd FileType python command! -buffer References call LanguageClient#textDocument_references()
            autocmd FileType python command! -buffer Definition call LanguageClient#textDocument_definition()
            " autocmd FileType python command! -buffer Implementation call LanguageClient#textDocument_implementation()
            autocmd FileType python command! -buffer Hover call LanguageClient#textDocument_hover()
            autocmd FileType python command! -buffer RenameSymbol call LanguageClient#textDocument_rename()
        endif
        if executable('pyls') || ( executable('cquery') || executable('clangd') )
            " autocmd FileType python,c,cpp autocmd CursorHold                                <buffer> call LanguageClient#textDocument_hover()
            " autocmd FileType python,c,cpp autocmd InsertEnter,CursorMoved,TermOpen,BufLeave <buffer> pclose
            autocmd FileType python,c,cpp command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
            autocmd FileType python,c,cpp command! -buffer DocumentSymbols call LanguageClient#textDocument_documentSymbol()
        endif
    augroup end
endif
