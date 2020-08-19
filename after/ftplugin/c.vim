" C settings
" github.com/mike325/.vim

setlocal cindent
setlocal foldmethod=syntax

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

if has#option('formatprg') && executable('clang-format')
    setlocal formatprg=clang-format\ --style=file\ --fallback-style=WebKit
endif

setlocal commentstring=//\ %s

if exists('g:c_includes')
    execute 'setlocal path^='.join(g:c_includes, ',')
endif

if executable('clang-tidy') && findfile('compile_commands.json', tr(getcwd(), '\', '/').';')
    setlocal makeprg=clang-tidy\ %
    let &l:errorformat = '%E%f:%l:%c: fatal error: %m,' .
        \                '%E%f:%l:%c: error: %m,' .
        \                '%W%f:%l:%c: warning: %m,' .
        \                '%-G%\m%\%%(LLVM ERROR:%\|No compilation database found%\)%\@!%.%#,' .
        \                '%E%m'
elseif executable('clang')
    setlocal makeprg=clang\ -Wall\ -Wextra\ -Weverything\ -Wno-missing-prototypes\ % " '-o', os#tmp('cpp')
elseif executable('gcc')
    setlocal makeprg=gcc\ -Wall\ -Wextra\ % " '-o', os#tmp('neomake')
endif

if has#plugin('neomake') && (executable('clang') || executable('clang-tidy') || executable('gcc'))
    call plugins#neomake#makeprg()
endif

nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>
