" C++ settings
" github.com/mike325/.vim

setlocal cindent
setlocal foldmethod=syntax

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

let &l:define = '^\(#\s*define\|[a-z]*\s*const\(expr\)\?\s*[a-z]*\)'

if executable('cppman')
    " Unfortunally Neovim works just with less as $PAGER
    if has('nvim') && ($PAGER ==# 'less')
        setlocal keywordprg=:term\ cppman
    elseif !has('nvim')
        " Vim works well as $PAGER with cppman
        setlocal keywordprg=cppman
    endif
endif

if has#option('formatprg') && executable('clang-format')
    setlocal formatprg=clang-format\ --style=file\ --fallback-style=WebKit
endif

setlocal commentstring=//\ %s

if exists('g:cpp_includes')
    execute 'setlocal path^='.join(g:cpp_includes, ',')
endif

if executable('clang-tidy') && findfile('compile_commands.json', tr(getcwd(), '\', '/').';')
    setlocal makeprg=clang-tidy\ %
    let &l:errorformat = '%E%f:%l:%c: fatal error: %m,' .
        \                '%E%f:%l:%c: error: %m,' .
        \                '%W%f:%l:%c: warning: %m,' .
        \                '%-G%\m%\%%(LLVM ERROR:%\|No compilation database found%\)%\@!%.%#,' .
        \                '%E%m'
elseif executable('clang++')
    setlocal makeprg=clang++\ -std=c++17\ -Wall\ -Wextra\ -Weverything\ -Wno-c++98-compat\ -Wno-missing-prototypes\ % " '-o', os#tmp('cpp')
elseif executable('g++')
    setlocal makeprg=g++\ -std=c++17\ -Wall\ -Wextra\ % " '-o', os#tmp('neomake')
endif

if has#plugin('neomake') && (executable('clang++') || executable('clang-tidy') || executable('g++'))
    call plugins#neomake#makeprg()
endif

nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>
