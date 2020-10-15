" Json Setttings
" github.com/mike325/.vim

if has#python()
    let s:python_prog = exists('g:python3_host_prog') ? g:python3_host_prog : g:python_host_prog
    let &formatprg = s:python_prog . ' -m json.tool'
endif

setlocal expandtab
setlocal shiftround
setlocal shiftwidth=2
setlocal tabstop=2
setlocal shiftwidth=0
setlocal softtabstop=-1

" Json is used as config files, this enables comments for them
setlocal commentstring=//\ %s

