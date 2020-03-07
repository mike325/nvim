" C settings
" github.com/mike325/.vim

setlocal cindent
setlocal foldmethod=syntax

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

if exists('+formatprg') && executable('clang-format')
    setlocal formatprg=clang-format
endif

setlocal commentstring=//\ %s

if exists('g:c_includes')
    execute 'setlocal path^='.join(g:c_includes, ',')
endif

if executable('clang-tidy') && filereadable(autocmd#getProjectRoot() . '/compile_commands.json')
    setlocal makeprg=clang-tidy\ %
    let &errorformat = '%E%f:%l:%c: fatal error: %m,' .
        \              '%E%f:%l:%c: error: %m,' .
        \              '%W%f:%l:%c: warning: %m,' .
        \              '%-G%\m%\%%(LLVM ERROR:%\|No compilation database found%\)%\@!%.%#,' .
        \              '%E%m'
elseif executable('clang')
    setlocal makeprg=clang\ -std=c17\ -Wall\ -Wextra\ -Weverything\ -Wno-missing-prototypes\ % " '-o', os#tmp('cpp')
elseif executable('gcc')
    setlocal makeprg=gcc\ -std=c17\ -Wall\ -Wextra\ % " '-o', os#tmp('neomake')
endif

if exists('g:plugs["neomake"]')
    call plugins#neomake#makeprg()
endif

nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>
