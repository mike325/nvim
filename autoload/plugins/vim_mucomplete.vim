" vim_mucomplete Setttings
" github.com/mike325/.vim

function! plugins#vim_mucomplete#init(data) abort
    if !exists('g:plugs["vim-mucomplete"]')
        return -1
    endif

    let g:mucomplete#enable_auto_at_startup = 1
    let g:mucomplete#no_mappings = 1
    let g:mucomplete#completion_delay = 10

    let g:mucomplete#ultisnips#match_at_start = 0

	let g:mucomplete#chains = {
	    \ 'default' : ['path', 'ulti', 'omni', 'keyn', 'dict', 'uspl'],
	    \ 'vim'     : ['path', 'ulti', 'cmd', 'keyn']
	    \ }

endfunction
