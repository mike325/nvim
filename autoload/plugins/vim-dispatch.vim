" vim-dispatch Setttings
" github.com/mike325/.vim

function! plugins#vim_dispatch#init(data) abort
    if !exists('g:plugs["vim-dispatch"]')
        return -1
    endif

    " let g:dispatch_handlers = [
    "     \ 'job',
    "     \ 'tmux',
    "     \ 'screen',
    "     \ 'windows',
    "     \ 'iterm',
    "     \ 'headless',
    "     \ ]
endfunction
