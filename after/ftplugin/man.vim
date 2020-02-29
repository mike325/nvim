" Man Setttings
" github.com/mike325/.vim

" setlocal foldmethod=syntax
setlocal bufhidden=delete
setlocal nomodifiable

setlocal nobackup
setlocal noswapfile
setlocal noundofile

setlocal number
setlocal relativenumber

nnoremap <silent> <nowait> <buffer> q :q!<CR>
nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>
