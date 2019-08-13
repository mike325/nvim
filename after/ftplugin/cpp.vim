" C++ settings
" github.com/mike325/.vim

setlocal cindent
setlocal foldmethod=syntax

if executable('cppman')
    " Unfortunally Neovim works just with less as $PAGER
    if has('nvim') && ($PAGER ==# 'less')
        setlocal keywordprg=:term\ cppman
    elseif !has('nvim')
        " Vim works well as $PAGER with cppman
        setlocal keywordprg=cppman
    endif
endif

if exists('+formatprg') && executable('clang-format')
    setlocal formatprg=clang-format
endif

setlocal commentstring=//\ %s

if exists('g:cpp_includes')
    execute 'setlocal path^='.join(g:cpp_includes, ',')
endif
