" Tagbar settings
" github.com/mike325/.vim

function! plugins#tagbar#init(data) abort
    if !exists('g:plugs["tagbar"]')
        return -1
    endif

    " Default is <Space> which conflict with my leader settings
    let g:tagbar_map_showproto = "<C-Space>"

    let g:tagbar_compact          = 0
    let g:tagbar_case_insensitive = 1
    let g:tagbar_show_visibility  = 1
    let g:tagbar_expand           = 1

    if empty($NO_COOL_FONTS)
        let g:tagbar_iconchars = ['▶', '▼']  " (default on Linux and Mac OS X)
    else
        let g:tagbar_iconchars = ['+', '-']   " (default on Windows)
    endif

    nnoremap _ :TagbarToggle<CR>

    " 0: Don't show any line numbers.
    " 1: Show absolute line numbers.
    " 2: Show relative line numbers.
    " -1: Use the global line number settings.
    "
    " NOTE: Since I already have a autocmd auto settings numbers
    " I will not enable this
    " let g:tagbar_show_linenumbers = 2

    " nnoremap tt :TagbarToggle<CR>
    " nnoremap <F2> :TagbarToggle<CR>
    " inoremap <F2> :TagbarToggle<CR>
    " vnoremap <F2> :TagbarToggle<CR>gv
endfunction
