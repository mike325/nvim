" Expand region settings
" github.com/mike325/.vim

function! plugins#vim_expand_region#init(data) abort
    if !exists('g:plugs["vim-expand-region"]')
        return -1
    endif

    " TODO improve expanding regions for common file types
    let g:expand_region_text_objects = {
        \ 'iw'  :0,
        \ 'iW'  :0,
        \ 'i"'  :0,
        \ 'i''' :0,
        \ 'i]'  :1,
        \ 'i)'  :1,
        \ 'il'  :0,
        \ 'ii'  :1,
        \ 'ip'  :0,
        \ 'i}'  :1,
        \ 'ie'  :0,
    \ }
endfunction
