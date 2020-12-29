" Zsh Setttings
" github.com/mike325/.vim

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>

if !has#plugin('nvim-treesitter')
    let g:zsh_fold_enable = 1
    setlocal foldmethod=syntax
endif

