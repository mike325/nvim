" EchoDoc settings
" github.com/mike325/.vim

function! plugins#echodoc_vim#init(data) abort
    if !exists('g:plugs["echodoc.vim"]')
        return -1
    endif

    let g:echodoc_enable_at_startup = 1
endfunction
