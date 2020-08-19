" Go Setttings
" github.com/mike325/.vim

if has#option('formatprg')
    if executable('gofmt')
        setlocal formatprg=gofmt
    endif
endif

setlocal foldmethod=syntax
nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>
