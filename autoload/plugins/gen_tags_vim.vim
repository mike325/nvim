" Gen_Tags settings
" github.com/mike325/.vim

function! plugins#gen_tags_vim#init(data) abort
    if !exists('g:plugs["gen_tags.vim"]')
        return -1
    endif

    " If we have async enable then auto update tags
    if has#async()
        let g:gen_tags#gtags_auto_gen = 1
        let g:gen_tags#ctags_auto_gen = 1
    endif
endfunction
