" C settings
" github.com/mike325/.vim

setlocal cindent
setlocal foldmethod=syntax

if exists('+formatprg') && executable('clang-format')
    setlocal formatprg=clang-format
endif

setlocal commentstring=//\ %s

if exists('g:c_includes')
    execute 'setlocal path^='.join(g:c_includes, ',')
endif
