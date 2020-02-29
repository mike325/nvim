" Help Setttings
" github.com/mike325/.vim

setlocal bufhidden=delete

setlocal number
setlocal relativenumber

setlocal nolist

setlocal nospell

nnoremap <silent> <nowait> <buffer> q :q!<CR>
nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>
