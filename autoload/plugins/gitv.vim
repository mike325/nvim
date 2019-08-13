" Gitv settings
" github.com/mike325/.vim

function! plugins#gitv#init(data) abort
    if !exists('g:plugs["gitv"]')
        return -1
    endif

    nnoremap <leader>gv :Gitv<CR>
endfunction
