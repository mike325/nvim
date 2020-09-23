" Dosini Setttings
" github.com/mike325/.vim

if has#option('formatprg') && executable('sed')
    " dosini config files must not have spaces at the beginning of the line
    setlocal formatprg=sed\ --regexp-extended\ \"s/^\\s+//\"
endif

setlocal comments=:;,:#
setlocal commentstring=;\ %s
