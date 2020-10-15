" Markdown Setttings
" github.com/mike325/.vim

setlocal spell
setlocal complete+=k,kspell " Add spell completion
setlocal foldmethod=indent
setlocal textwidth=80

if has('nvim-0.4')
    lua require"tools".abolish(require'nvim'.o.spelllang)
else
    call tools#abolish(&l:spelllang)
endif
