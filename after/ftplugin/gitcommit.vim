" gitcommit Setttings
" github.com/mike325/.vim

setlocal bufhidden=delete
setlocal noreadonly

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
