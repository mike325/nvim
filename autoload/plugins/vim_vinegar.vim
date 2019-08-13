" Vinegar settings
" github.com/mike325/.vim

function! plugins#vim_vinegar#init(data) abort
    if !exists('g:plugs["vim-vinegar"]')
        return -1
    endif

    " Fucking shit causes tons of problems
    " let g:netrw_liststyle=3
endfunction
