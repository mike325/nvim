" dosini Setttings
" github.com/mike325/.vim

autocmd BufNewFile,BufReadPre,BufEnter *.{ini,toml},.coveragerc setlocal filetype=dosini
