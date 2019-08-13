" Gonvimfuzzy Setttings
" github.com/mike325/.vim

function! plugins#gonvim_fuzzy#init(data) abort
    if !exists('g:gonvim_running') || !exists('g:plugs["gonvim-fuzzy"]')
        return -1
    endif

    nnoremap <C-p> :GonvimFuzzyFiles<CR>
    nnoremap <C-b> :GonvimFuzzyBuffers<CR>
endfunction
