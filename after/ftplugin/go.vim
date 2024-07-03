" Go Settings
" github.com/mike325/.vim

if has#option('formatprg')
    if executable('gofmt')
        setlocal formatprg=gofmt
    endif
endif

setlocal noexpandtab
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1
setlocal foldmethod=syntax
nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>
