" Help Setttings
" github.com/mike325/.vim

setlocal bufhidden=delete

setlocal number
setlocal relativenumber

setlocal nolist

setlocal nospell

nnoremap <silent> <buffer> q :q!<CR>
nnoremap <buffer> <CR> :call mappings#cr()<CR>
