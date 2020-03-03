" vim_mucomplete Setttings
" github.com/mike325/.vim

if !exists('g:plugs["vim-mucomplete"]') && exists('g:config_mucomplete')
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

let s:cpp_cond  = { t -> t =~# '\%(->\|::\|\.\)\(\a[[:alnum:]]\+\)\?$' }
let s:c_cond    = { t -> t =~# '\%(->\|\.\)\(\a[[:alnum:]]\+\)\?$' }
let s:lua_cond  = { t -> t =~# '\%(:\|\.\)\(\a[[:alnum:]]\+\)\?$' }
let s:omni_cond = { t -> t =~# '\%(\.\)\(\a[[:alnum:]]\+\)\?$' }

let g:mucomplete#can_complete = get(g:, 'mucomplete#can_complete', {})
let g:mucomplete#can_complete.c      = { 'omni': s:c_cond }
let g:mucomplete#can_complete.cpp    = { 'omni': s:cpp_cond }
let g:mucomplete#can_complete.lua    = { 'omni': s:lua_cond }
let g:mucomplete#can_complete.python = { 'omni': s:omni_cond }
