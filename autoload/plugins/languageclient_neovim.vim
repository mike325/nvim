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

augroup LanguageCmds
    autocmd!
augroup end

function! plugins#languageclient_neovim#install(info) abort
    if os#name('windows')
        execute '!powershell -executionpolicy bypass -File ./install.ps1'
    else
        execute '!./install.sh'
    endif
    UpdateRemotePlugins
endfunction

function! s:Rename(name) abort
    if !empty(a:name)
        call LanguageClient#textDocument_rename({'newName': a:name})
    else
        call LanguageClient#textDocument_rename()
    endif
endfunction


function! plugins#languageclient_neovim#LanguageMappings() abort
    if has_key(g:LanguageClient_serverCommands, &filetype)
        command! -buffer -nargs=? RenameSymbol      call s:Rename(<q-args>)
        command! -buffer          Definition        call LanguageClient#textDocument_definition()
        command! -buffer          Hover             call LanguageClient#textDocument_hover()
        command! -buffer          Implementation    call LanguageClient#textDocument_implementation()
        command! -buffer          References        call LanguageClient#textDocument_references()
        command! -buffer          DocumentSymbols   call LanguageClient#textDocument_documentSymbol()

        nnoremap <buffer> <silent> K    :call LanguageClient#textDocument_hover()<CR>
        nnoremap <buffer> <silent> gD   :call LanguageClient#textDocument_definition()<CR>

    endif
endfunction

function! plugins#languageclient_neovim#init(data) abort
    if !exists('g:plugs["LanguageClient-neovim"]')
        return -1
    endif

    let l:supported_languages = []

    let g:LanguageClient_serverCommands    = get(g:, 'LanguageClient_serverCommands', {})
    let g:LanguageClient_loggingLevel      = 'WARN'
    let g:LanguageClient_loggingFile       = os#tmp('languageclient.log')
    let g:LanguageClient_hoverPreview      = 'Auto'
    let g:LanguageClient_hasSnippetSupport = 0

    if has('nvim-0.3.2')
        let g:LanguageClient_useVirtualText    = 1
    endif

    if has('nvim-0.4')
        let g:LanguageClient_useFloatingHover = 1
    endif

    if !executable('fzf')
        let g:LanguageClient_fzfContextMenu = 0
    endif

    if exists('g:plugs["neomake"]')
        let g:LanguageClient_diagnosticsEnable = 0
    endif

    " Cleanup
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

        let l:supported_languages += ['c', 'cpp']

        if executable('ccls') || executable('cquery')
            autocmd LanguageCmds FileType c,cpp command! -buffer Callers call LanguageClient#cquery_callers()
        endif

        augroup LanguageCmds
            autocmd FileType c,cpp autocmd CursorHold <buffer> call LanguageClient#textDocument_hover()
            autocmd FileType c,cpp command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
        augroup end

        if executable('ccls')
            let g:LanguageClient_serverCommands.cuda = g:LanguageClient_serverCommands.c
            let g:LanguageClient_serverCommands.objc = g:LanguageClient_serverCommands.c
            let l:supported_languages += ['cuda', 'objc']
            augroup LanguageCmds
                autocmd FileType cuda,objc autocmd CursorHold  <buffer> call LanguageClient#textDocument_hover()
                autocmd FileType cuda,objc command! -buffer Callers call LanguageClient#cquery_callers()
                autocmd FileType cuda,objc command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
            augroup end
        endif

    endif

    if executable('bash-language-server')
        let g:LanguageClient_serverCommands.sh = ['bash-language-server', 'start']
        let g:LanguageClient_serverCommands.bash = g:LanguageClient_serverCommands.sh
        let l:supported_languages += ['sh', 'bash']
        autocmd LanguageCmds FileType sh,bash autocmd CursorHold <buffer> call LanguageClient#textDocument_hover()
    endif

    if executable('pyls')
        let g:LanguageClient_serverCommands.python = ['pyls', '--log-file=' . os#tmp('pyls.log')]
        let l:supported_languages += ['python']
        augroup LanguageCmds
            autocmd FileType python autocmd CursorHold <buffer> call LanguageClient#textDocument_hover()
            autocmd FileType python command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
        augroup end
    endif

    if !empty(l:supported_languages)
        execute 'autocmd LanguageCmds FileType '.join(l:supported_languages).' call plugins#languageclient_neovim#LanguageMappings()'
    endif

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
endfunction
