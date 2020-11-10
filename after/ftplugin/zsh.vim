" Zsh Setttings
" github.com/mike325/.vim

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

" Since '$' is part of the variables, lets treat it as part of the word
" setlocal iskeyword+=$
" let g:is_zsh = 1

let g:zsh_fold_enable = 1
setlocal foldmethod=syntax

nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>
