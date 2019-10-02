" Signify settings
" github.com/mike325/.vim

function! plugins#vim_signify#init(data) abort
    if !exists('g:plugs["vim-signify"]')
        return -1
    endif

    let g:signify_cursorhold_insert     = 1
    let g:signify_cursorhold_normal     = 1
    let g:signify_update_on_focusgained = 1
    let g:signify_update_on_bufenter    = 0


    let g:signify_skip_filetype = {
                \    'log': 1,
                \ }

    let g:signify_skip_filename_pattern = [
                \   '*.log',
                \ ]

    nmap ]h <plug>(signify-next-hunk)
    nmap [h <plug>(signify-prev-hunk)
    " nmap ]h 9999<leader>gj
    " nmap ]h 9999<leader>gk

    omap ih <plug>(signify-motion-inner-pending)
    xmap ih <plug>(signify-motion-inner-visual)
    omap ah <plug>(signify-motion-outer-pending)
    xmap ah <plug>(signify-motion-outer-visual)

    nnoremap <silent> =p :SignifyHunkPreview<CR>
    nnoremap <silent> =u :SignifyHunkUndo<CR>
endfunction
