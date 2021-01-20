" Help Setttings
" github.com/mike325/.vim

" setlocal bufhidden=delete
setlocal number
setlocal relativenumber
setlocal nospell
setlocal buflisted
setlocal nolist

nnoremap <silent> <nowait> <buffer> q :q!<CR>
nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>

" nnoremap <silent><buffer> <bs> :call mappings#bs()<CR>
