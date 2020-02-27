" Deoplete and plugins settings
" github.com/mike325/.vim

function! plugins#deoplete_nvim#init(data) abort
    if !exists('g:plugs["deoplete.nvim"]')
        return -1
    endif

    let g:deoplete#enable_at_startup = 1

    try
        call deoplete#custom#option({
        \   'auto_complete_delay': 20,
        \   'smart_case': 1,
        \   'min_keyword_length': 2,
        \ })
    catch E117
        let g:deoplete#enable_refresh_always             = 1
        let g:deoplete#enable_smart_case                 = 1
        let g:deoplete#sources#syntax#min_keyword_length = 2
        let g:deoplete#auto_complete_delay               = 20
    endtry

endfunction
