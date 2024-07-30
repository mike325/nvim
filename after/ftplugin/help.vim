" Help Settings
" github.com/mike325/.vim

" setlocal bufhidden=delete
setlocal nomodifiable
setlocal nobackup
setlocal noswapfile
setlocal noundofile
setlocal nolist
setlocal nowrap
setlocal number
setlocal relativenumber
setlocal buflisted

nnoremap <buffer><silent><nowait> q :q!<CR>
nnoremap <buffer><silent><nowait> <CR> <C-]>
nnoremap <buffer><silent><nowait> <CR> :call mappings#cr()<CR>
