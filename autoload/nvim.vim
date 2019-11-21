" Nvim Setttings
" github.com/mike325/.vim

" let s:load_remotes = 0

" augroup UpdateRemotes
"     autocmd!
"     autocmd VimEnter * if s:load_remotes == 1 | UpdateRemotePlugins | endif
" augroup end

function! nvim#updateremoteplugins(info) abort
    if has('nvim')
        let s:load_remotes = 1
    endif
endfunction

function! nvim#LanguageMappings() abort
    if tools#CheckLanguageServer(&filetype)
        command! -buffer  Definition      call lsp#text_document_definition()
        command! -buffer  Declaration     call lsp#text_document_declaration()
        command! -buffer  Hover           call lsp#text_document_hover()
        command! -buffer  Implementation  call lsp#text_document_implementation()
        command! -buffer  Signature       call lsp#text_document_signature_help()
        command! -buffer  Type            call lsp#text_document_type_definition()

        nnoremap <buffer> <silent> K    :call lsp#text_document_hover()<CR>
        nnoremap <buffer> <silent> gD   :call lsp#text_document_definition()<CR>

    endif
endfunction

function! nvim#lsp() abort
    " Cleanup
    augroup LanguageCmds
        autocmd!
    augroup end

    let l:supported_languages = []

    if tools#CheckLanguageServer('c')
        let l:supported_languages += ['c', 'cpp']
        if executable('ccls') || executable('cquery')
            let l:supported_languages += ['cuda', 'objc']
        endif
    endif

    if tools#CheckLanguageServer('python')
        let l:supported_languages += ['python']
    endif

    if tools#CheckLanguageServer('sh')
        let l:supported_languages += ['sh', 'bash']
    endif

    if !empty(l:supported_languages)
        execute 'autocmd LanguageCmds FileType '.join(l:supported_languages, ',').' setlocal omnifunc=lsp#omnifunc'
        execute 'autocmd LanguageCmds FileType '.join(l:supported_languages, ',').' call nvim#LanguageMappings()'
    endif


endfunction

function! nvim#init() abort
    if !has('nvim')
        return -1
    endif
    " Disable some vi compatibility
    if !exists('g:plugs["traces.vim"]')
        " Live substitute preview
        set inccommand=split
    endif

    if executable('nvr')
        " Add Neovim remote utility, this allow us to open buffers from the :terminal cmd
        let $nvr = 'nvr --remote-silent'
        let $tnvr = 'nvr --remote-tab-silent'
        let $vnvr = 'nvr -cc vsplit --remote-silent'
        let $snvr = 'nvr -cc split --remote-silent'
    endif

    if has('nvim-0.2')
        set cpoptions-=_
    endif

    let g:terminal_scrollback_buffer_size = 100000

    " always show signcolumns
    if has('nvim-0.2')
        set signcolumn=auto
    endif

    if exists('g:gonvim_running')
        " Use Gonvim UI instead of (Neo)vim native GUI/TUI

        " set laststatus=0
        set noshowmode
        set noruler

        if exists('g:plugs["gonvim-fuzzy"]')
            let g:gonvim_fuzzy_ag_cmd = tools#grep('rg', 'grepprg')
        endif

    else
        set titlestring=%t\ (%f)
        set title          " Set window title
    endif


    if has('nvim-0.5') && tools#CheckLanguageServer()
        call nvim#lsp()
    endif

endfunction
