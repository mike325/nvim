" Vim_textobj_comment Settings
" github.com/mike325/.vim

if !has#plugin('vim-textobj-comment') || exists('g:config_textobj')
    finish
endif

let g:config_textobj = 1

augroup PostTextObjComments
    autocmd!
    autocmd VimEnter * silent! execute 'TextobjCommentDefaultKeyMappings!'
augroup end
