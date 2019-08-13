" JavaComplete settings
" github.com/mike325/.vim

function! plugins#vim_javacomplete2#init(data) abort
    if !exists('g:plugs["vim-javacomplete2"]')
        return -1
    endif

    nnoremap <leader>si <Plug>(JavaComplete-Imports-AddSmart)
    nnoremap <leader>mi <Plug>(JavaComplete-Imports-AddMissing)
endfunction
