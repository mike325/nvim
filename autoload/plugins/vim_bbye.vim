" Vim-bbye settings
" github.com/mike325/.vim

function! plugins#vim_bbye#init(data) abort
    if !exists('g:plugs["vim-bbye"]')
        return -1
    endif

    " Better behave buffer deletion
    nnoremap <leader>d :Bdelete!<CR>
endfunction
