" Vim-bbye settings
" github.com/mike325/.vim

if !exists('g:plugs["vim-bbye"]') || exists('g:config_bbye')
    finish
endif

let g:config_bbye = 1

" Better behave buffer deletion
nnoremap <leader>d :Bdelete!<CR>
