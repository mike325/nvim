" gitcommit Setttings
" github.com/mike325/.vim

setlocal bufhidden=delete
setlocal noreadonly

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

setlocal modifiable
setlocal nobackup
setlocal noswapfile

setlocal spell
setlocal complete+=k,kspell " Add spell completion

setlocal textwidth=80

if has('nvim-0.4')
    call luaeval('tools.abolish("'.&l:spelllang.'")')
else
    call tools#abolish(&l:spelllang)
endif
