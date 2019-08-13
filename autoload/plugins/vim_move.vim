" Vim move settings
" github.com/mike325/.vim

function! plugins#vim_move#init(data) abort
    if !exists('g:plugs["vim-move"]')
        return -1
    endif

    " Manual map the functions to overlap any possible conflict
    let g:move_key_modifier = 'C'

    " let g:move_map_keys = 0
    " Set Ctrl key as default. Commands <C-j> and <C-k> to move stuff
    " vnoremap <C-j> <Plug>MoveBlockDown
    " vnoremap <C-k> <Plug>MoveBlockUp

    " nnoremap <C-j> <Plug>MoveLineDown
    " nnoremap <C-k> <Plug>MoveLineUp
    " nmap <>     <Plug>MoveBlockHalfPageDown
endfunction
