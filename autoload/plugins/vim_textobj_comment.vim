" Vim_textobj_comment Setttings
" github.com/mike325/.vim

if !exists('g:plugs["vim-textobj-comment"]') || exists('g:config_textobj')
    finish
endif

let g:config_textobj = 1

augroup PostTextObjComments
    autocmd!
    autocmd VimEnter * silent! execute 'TextobjCommentDefaultKeyMappings!'
augroup end
