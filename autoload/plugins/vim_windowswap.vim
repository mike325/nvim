" Windowswap.vim Setttings
" github.com/mike325/.vim

function! plugins#vim_windowswap#init(data) abort
    if !exists('g:plugs["vim-windowswap"]')
        return -1
    endif

    let g:windowswap_map_keys = 0
    nnoremap <silent> <leader><leader>w :call WindowSwap#EasyWindowSwap()<CR>

    " This is an old deprecated mapping anyway
    silent! unmap <leader>pw
    silent! unmap <leader>yw
endfunction
