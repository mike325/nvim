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

" TODO: I had had some probles with pysl in windows, so let's
"       skip it until I can figure it out how to fix this
if executable('pyls') && !WINDOWS()
    let g:LanguageClient_serverCommands.python = ['pyls', '--log-file=' . s:log_dir . '/pyls.log']
endif

function! s:Rename(name)
    if !empty(a:name)
        call LanguageClient#textDocument_rename({'newName': a:name})
    else
        call LanguageClient#textDocument_rename()
    endif
endfunction

augroup LanguageCmds
    autocmd!
    if executable('cquery')
        autocmd FileType c,cpp command! -buffer Callers call LanguageClient#cquery_callers()
    endif
    " autocmd FileType python,c,cpp autocmd CursorHold                                <buffer> call LanguageClient#textDocument_hover()
    " autocmd FileType python,c,cpp autocmd InsertEnter,CursorMoved,TermOpen,BufLeave <buffer> pclose
    if !WINDOWS()
        autocmd FileType python,c,cpp command! -buffer References call LanguageClient#textDocument_references()
        if !exists('g:plugs["denite.nvim"]')
            autocmd FileType python,c,cpp command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
            autocmd FileType python,c,cpp command! -buffer DocumentSymbols call LanguageClient#textDocument_documentSymbol()
        else
            autocmd FileType python,c,cpp command! -buffer WorkspaceSymbols Denite -highlight-mode-insert=off -highlight-matched-range=off -prompt='WorkSymbols >'     -buffer-name=DeniteBuffer('worksym_') workspaceSymbol
            autocmd FileType python,c,cpp command! -buffer DocumentSymbols  Denite -highlight-mode-insert=off -highlight-matched-range=off -prompt='DocumentSymbols >' -buffer-name=DeniteBuffer('docsym_') documentSymbol
        endif
        autocmd FileType python,c,cpp command! -nargs=? -buffer RenameSymbol call s:Rename(<q-args>)
        autocmd FileType python,c,cpp command! -buffer Definition call LanguageClient#textDocument_definition()
        autocmd FileType python,c,cpp command! -buffer Hover call LanguageClient#textDocument_hover()
        autocmd FileType python,c,cpp command! -buffer Implementation call LanguageClient#textDocument_implementation()
    else
        autocmd FileType c,cpp command! -buffer References call LanguageClient#textDocument_references()
        autocmd FileType c,cpp command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
        autocmd FileType c,cpp command! -buffer DocumentSymbols call LanguageClient#textDocument_documentSymbol()
        autocmd FileType c,cpp command! -nargs=? -buffer RenameSymbol call s:Rename(<q-args>)
        autocmd FileType c,cpp command! -buffer Definition call LanguageClient#textDocument_definition()
        autocmd FileType c,cpp command! -buffer Hover call LanguageClient#textDocument_hover()
        autocmd FileType c,cpp command! -buffer Implementation call LanguageClient#textDocument_implementation()
    endif
augroup end

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
