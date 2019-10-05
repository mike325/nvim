scriptencoding 'utf-8'
" DelimitMate settings
" github.com/mike325/.vim

function! plugins#delimitmate#init(data) abort
    if !exists('g:plugs["delimitMate"]')
        return -1
    endif

    let g:delimitMate_expand_space = 1

    " let delimitMate_matchpairs = "(:),[:],{:},<:>"
    augroup DelimitMaters
        autocmd!
        autocmd FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
        autocmd FileType text let b:delimitMate_matchpairs = "(:),[:],{:},<:>,¿:?,¡:!"
        autocmd FileType c,cpp,java,perl let b:delimitMate_eol_marker = ";"
    augroup end

    " iunmap <BS>
    if exists('*delimitMate#BS')
        imap <silent> <BS> <Plug>delimitMateBS
    endif

endfunction
