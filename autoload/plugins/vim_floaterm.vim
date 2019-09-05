" vim_floaterm Setttings
" github.com/mike325/.vim

function! plugins#vim_floaterm#init(data) abort
    if !exists('g:plugs["vim-floaterm"]')
        return -1
    endif

    let g:floaterm_height = (winheight(0) / 2)
    let g:floaterm_width = (&columns / 2) + 10
endfunction
