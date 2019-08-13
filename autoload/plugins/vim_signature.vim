" Signature  settings
" github.com/mike325/.vim

function! plugins#vim_signature#init(data) abort
    if !exists('g:plugs["vim-signature"]')
        return -1
    endif

    " nnoremap <leader><leader>g :SignatureListGlobalMarks<CR>
    " inoremap <C-s>g <ESC>:SignatureListGlobalMarks<CR>

    " nnoremap <leader><leader>b :SignatureListBufferMarks<CR>
    " inoremap <C-s>b <ESC>:SignatureListBufferMarks<CR>

    " nnoremap tS :SignatureToggleSigns<CR>
endfunction
