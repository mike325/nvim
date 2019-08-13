" Search plugins settings
" github.com/mike325/.vim

function! plugins#vim_slash#init(data) abort
    if !exists('g:plugs["vim-slash"]') && !exists('g:plugs["vim-indexed-search"]')
        return -1
    endif

    let g:indexed_search_mappings = 0
    noremap <silent> <Plug>(slash-after) :<C-u>ShowSearchIndex<CR>
    xunmap <Plug>(slash-after)
endfunction
