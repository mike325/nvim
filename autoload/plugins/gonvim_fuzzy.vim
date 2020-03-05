" Gonvimfuzzy Setttings
" github.com/mike325/.vim

if (!exists('g:gonvim_running') || !exists('g:plugs["gonvim-fuzzy"]')) || exists('g:config_gonvim')
    finish
endif

let g:config_gonvim = 1

nnoremap <C-p> :GonvimFuzzyFiles<CR>
nnoremap <C-b> :GonvimFuzzyBuffers<CR>
