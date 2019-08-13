" Log Setttings
" github.com/mike325/.vim

function! CheckSize()
    " If the size of the file is bigger than ~5MB
    " lets consider it as a log
    return ( getfsize(expand('%')) > 5242880 ) ? 1 : 0
endfunction


autocmd BufNewFile,BufReadPre,BufEnter *.log,*.rpt,*.rdl setlocal filetype=log
autocmd BufNewFile,BufReadPre,BufEnter *.txt if ( CheckSize() == 1 ) | setlocal filetype=log | endif
