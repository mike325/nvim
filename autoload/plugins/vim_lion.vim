" Lion settings
" github.com/mike325/.vim

if !exists('g:plugs["vim-lion"]') && exists('g:config_lion')
    finish
endif

let g:config_lion = 1

let g:lion_squeeze_spaces = 1
