" Quickfix settings
" github.com/mike325/.vim

packadd cfilter
let g:loaded_cfilter = v:true

setlocal colorcolumn=
setlocal nospell

nnoremap <buffer> <CR> <CR>
nnoremap <silent> <nowait> <buffer> q :q!<CR>

if !has#plugin('nvim-bqf')
    nnoremap <buffer> o <CR><cmd>call execute(getwininfo(win_getid())[0].loclist == 1 ? 'lclose' : 'cclose')<CR>

    nnoremap <buffer> < <cmd>call execute(getwininfo(win_getid())[0].loclist == 1 ? 'lolder' : 'colder')<CR>
    nnoremap <buffer> > <cmd>call execute(getwininfo(win_getid())[0].loclist == 1 ? 'lnewer' : 'cnewer')<CR>
endif
