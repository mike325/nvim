" gitconfig Setttings
" github.com/mike325/.vim

autocmd BufNewFile,BufReadPre,BufEnter gitconfig,*.git/config,*/git/config setlocal filetype=gitconfig
