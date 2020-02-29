" Go Setttings
" github.com/mike325/.vim

if exists('+formatprg')
    if executable('gofmt')
        setlocal formatprg=gofmt
    endif
endif

setlocal foldmethod=syntax
nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>
