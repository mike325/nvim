" Dosini Settings
" github.com/mike325/.vim

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

setlocal comments=:;,:#
setlocal commentstring=;\ %s

if has#option('formatprg') && executable('sed')
    " dosini config files must not have spaces at the beginning of the line
    setlocal formatprg=sed\ --regexp-extended\ \"s/^\\s+//\"
endif
