scriptencoding 'utf-8'

" Surround Setttings
" github.com/mike325/.vim

if !has#plugin('vim-surround') || exists('g:config_surround')
    finish
endif

let g:config_surround = 1

let g:surround_{char2nr("¿")} = "¿\r?"
let g:surround_{char2nr("?")} = "¿\r?"
let g:surround_{char2nr("¡")} = "¡\r!"
let g:surround_{char2nr("!")} = "¡\r!"
let g:surround_{char2nr(";")} = ":\r:"
let g:surround_{char2nr(":")} = ":\r:"
let g:surround_{char2nr('q')} = "``\r''"
