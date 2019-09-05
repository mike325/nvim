" Help Setttings
" github.com/mike325/.vim

setlocal bufhidden=delete

setlocal number
setlocal relativenumber

setlocal nospell

nnoremap <silent> <buffer> q :q!<CR>
nnoremap <silent> <buffer> <CR> <C-]>
nnoremap <silent> <buffer> <BS> <C-t>

if has('nvim') && os#name('windows') && !has#gui()
    nnoremap <silent> <buffer> <C-h> <C-t>
endif
