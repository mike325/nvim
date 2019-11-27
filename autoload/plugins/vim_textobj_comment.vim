" Vim_textobj_comment Setttings
" github.com/mike325/.vim

function! plugins#vim_textobj_comment#init(data) abort
    if !exists('g:plugs["vim-textobj-comment"]')
        return -1
    endif

    augroup PostTextObjComments
        autocmd!
        autocmd VimEnter * silent! execute 'TextobjCommentDefaultKeyMappings!'
    augroup end
endfunction
