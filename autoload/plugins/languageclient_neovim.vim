" Languageclient Setttings
" github.com/mike325/.vim

function! plugins#languageclient_neovim#install(info) abort
    if os#name('windows')
        execute '!powershell -executionpolicy bypass -File ./install.ps1'
    else
        execute '!./install.sh'
    endif
    silent! UpdateRemotePlugins
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
        " execute 'autocmd LanguageCmds FileType '.&filetype.' autocmd CursorHold  <buffer> call LanguageClient#textDocument_hover()'
        " if has('nvim-0.4')
        "     " TODO: Close float buffer
        "     " autocmd LanguageCmds FileType &filetype autocmd InsertEnter,CursorMoved,TermOpen,BufLeave <buffer> pclose
        " else
        "     execute 'autocmd LanguageCmds FileType '.&filetype.' autocmd InsertEnter,CursorMoved,TermOpen,BufLeave <buffer> pclose'
        " endif
        command! -buffer -nargs=? RenameSymbol      call s:Rename(<q-args>)
        command! -buffer          Definition        call LanguageClient#textDocument_definition()
        command! -buffer          Hover             call LanguageClient#textDocument_hover()
        command! -buffer          Implementation    call LanguageClient#textDocument_implementation()
        command! -buffer          References        call LanguageClient#textDocument_references({'includeDeclaration': v:true})
        command! -buffer          DocumentSymbols   call LanguageClient#textDocument_documentSymbol()

        nnoremap <buffer> <silent> K    :call LanguageClient#textDocument_hover()<CR>
        nnoremap <buffer> <silent> gD   :call LanguageClient#textDocument_definition()<CR>
        nnoremap <buffer> <silent> gsr  :call LanguageClient#textDocument_references({'includeDeclaration': v:true})<CR>

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
    let g:LanguageClient_diagnosticsList   = 'Location'
    let g:LanguageClient_hoverPreview      = 'Always'

    let g:LanguageClient_diagnosticsEnable = !exists('g:plugs["neomake"]') ? 1 : 0

    if has('nvim-0.3.2')
        let g:LanguageClient_useVirtualText = 1
    endif

    if has('nvim-0.4')
        let g:LanguageClient_useFloatingHover = 1
    endif

    if !executable('fzf')
        let g:LanguageClient_fzfContextMenu = 0
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

        autocmd LanguageCmds FileType c,cpp command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()

        if executable('ccls')
            function! s:C_mappings() abort
                " bases
                nnoremap <buffer> <silent> gsb :call LanguageClient#findLocations({'method':'$ccls/inheritance'})<CR>
                " bases of up to 3 levels
                nnoremap <buffer> <silent> gsB :call LanguageClient#findLocations({'method':'$ccls/inheritance','levels':3})<CR>
                " derived
                nnoremap <buffer> <silent> gsd :call LanguageClient#findLocations({'method':'$ccls/inheritance','derived':v:true})<CR>
                " derived of up to 3 levels
                nnoremap <buffer> <silent> gsD :call LanguageClient#findLocations({'method':'$ccls/inheritance','derived':v:true,'levels':3})<CR>

                " caller
                nnoremap <buffer> <silent> gsc :call LanguageClient#findLocations({'method':'$ccls/call'})<CR>
                " callee
                nnoremap <buffer> <silent> gsC :call LanguageClient#findLocations({'method':'$ccls/call','callee':v:true})<CR>

                " $ccls/member
                " nested classes / types in a namespace
                nnoremap <buffer> <silent> gss :call LanguageClient#findLocations({'method':'$ccls/member','kind':2})<CR>
                " member functions / functions in a namespace
                nnoremap <buffer> <silent> gsf :call LanguageClient#findLocations({'method':'$ccls/member','kind':3})<CR>
                " member variables / variables in a namespace
                nnoremap <buffer> <silent> gsm :call LanguageClient#findLocations({'method':'$ccls/member'})<CR>

                " nnoremap <buffer> <silent> ss s
            endfunction

            augroup LanguageClient_config
                autocmd FileType c,cpp,cuda,objc call s:C_mappings()
                " autocmd FileType c,cpp,cuda,objc autocmd CursorMoved *.{c,cpp,h,hpp,hxx,cxx,C,CC} silent call LanguageClient#textDocument_documentHighlight()
            augroup end

            let g:LanguageClient_serverCommands.cuda = g:LanguageClient_serverCommands.c
            let g:LanguageClient_serverCommands.objc = g:LanguageClient_serverCommands.c
            let l:supported_languages += ['cuda', 'objc']

            augroup LanguageCmds
                autocmd FileType cuda,objc command! -buffer Callers call LanguageClient#cquery_callers()
                autocmd FileType cuda,objc command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
            augroup end
        endif

    endif

    if executable('bash-language-server')
        let g:LanguageClient_serverCommands.sh = ['bash-language-server', 'start']
        let g:LanguageClient_serverCommands.bash = g:LanguageClient_serverCommands.sh
        let l:supported_languages += ['sh', 'bash']
    endif

    if executable('pyls')
        let g:LanguageClient_serverCommands.python = ['pyls', '--log-file=' . os#tmp('pyls.log')]
        let l:supported_languages += ['python']
        autocmd  LanguageCmds FileType python command! -buffer WorkspaceSymbols call LanguageClient#workspace_symbol()
    endif

    if !empty(l:supported_languages)
        execute 'autocmd LanguageCmds FileType '.join(l:supported_languages, ',').' call plugins#languageclient_neovim#LanguageMappings()'
    endif

    " if exists('g:plugs["vim-abolish"]')
    "     noremap gsrc :call LanguageClient#textDocument_rename({'newName': Abolish.camelcase(expand('<cword>'))})<CR>
    "     noremap gsrs :call LanguageClient#textDocument_rename({'newName': Abolish.snakecase(expand('<cword>'))})<CR>
    "     noremap gsru :call LanguageClient#textDocument_rename({'newName': Abolish.uppercase(expand('<cword>'))})<CR>
    " endif
endfunction
