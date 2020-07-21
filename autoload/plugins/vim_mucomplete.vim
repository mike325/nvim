" vim_mucomplete Setttings
" github.com/mike325/.vim

if !exists('g:plugs["vim-mucomplete"]') || exists('g:config_mucomplete')
    finish
endif

let g:config_mucomplete = 1

let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#no_mappings = 1
let g:mucomplete#completion_delay = 10

let g:mucomplete#ultisnips#match_at_start = 0

let g:mucomplete#chains = {
    \ 'default' : ['path', 'ulti', 'omni', 'keyn', 'dict', 'uspl'],
    \ 'vim'     : ['path', 'ulti', 'cmd', 'keyn']
    \ }

let g:mucomplete#can_complete = get(g:, 'mucomplete#can_complete', {})

function! plugins#vim_mucomplete#setOmni() abort

    let l:omni = {
        \ 'cpp':    { t -> t =~# '\%(->\|::\|\.\)' },
        \ 'c':      { t -> t =~# '\%(->\|\.\)' },
        \ 'lua':    { t -> t =~# '\%(:\|\.\)' },
        \ 'python': { t -> t =~# '\%(\.\)' },
        \ 'tex':    { t -> t =~# '\\' },
        \}

    let l:ft = &filetype

    if empty(l:ft) || !exists('l:omni[l:ft]') || &omnifunc !=# 'v:lua.vim.lsp.omnifunc'
        return
    endif

    let g:mucomplete#can_complete[l:ft] = { 'omni': l:omni[l:ft] }

endfunction
