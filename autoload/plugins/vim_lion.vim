" Lion settings
" github.com/mike325/.vim

function! plugins#vim_lion#init(data) abort
    if !exists('g:plugs["vim-lion"]')
        return -1
    endif

    let g:lion_squeeze_spaces = 1
endfunction
