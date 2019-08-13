" Tabular settigns
" github.com/mike325/.vim

function! plugins#tabular#init(data) abort
    if !exists('g:plugs["tabular"]')
        return -1
    endif

    nnoremap <leader>t= :Tabularize /=<CR>
    xnoremap <leader>t= :Tabularize /=<CR>

    nnoremap <leader>t: :Tabularize /:<CR>
    xnoremap <leader>t: :Tabularize /:<CR>

    nnoremap <leader>t" :Tabularize /"<CR>
    xnoremap <leader>t" :Tabularize /"<CR>

    nnoremap <leader>t# :Tabularize /#<CR>
    xnoremap <leader>t# :Tabularize /#<CR>

    nnoremap <leader>t* :Tabularize /*<CR>
    xnoremap <leader>t* :Tabularize /*<CR>
endfunction
