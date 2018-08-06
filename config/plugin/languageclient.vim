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


if executable('cquery')
    let g:LanguageClient_serverCommands.c = ['cquery', '--log-file=/tmp/cq.log', '--init={"cacheDirectory":"' . g:home . '/.cache/cquery", "completion": {"filterAndSort": false}}']
    let g:LanguageClient_serverCommands.cpp = g:LanguageClient_serverCommands.c
endif

if executable('pyls')
    let g:LanguageClient_serverCommands.python = ['pyls']
endif

if executable('pyls') || executable('cquery')
    augroup LanguageCmds
        autocmd!
        if executable('cquery')
            autocmd FileType c,cpp command! -buffer Callers call LanguageClient#cquery_callers()
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
    augroup end
endif
