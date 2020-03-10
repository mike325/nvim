" txt Setttings
" github.com/mike325/.vim

autocmd BufNewFile,BufRead *.txt if ( tools#checksize() == 1 ) | setlocal filetype=log | endif
autocmd BufNewFile,BufRead www.overleaf.com_*.txt setlocal filetype=tex
autocmd BufNewFile,BufRead github.com_*.txt       setlocal filetype=markdown
