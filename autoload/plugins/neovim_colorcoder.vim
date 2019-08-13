" Colorcoder Setttings
" github.com/mike325/.vim

function! plugins#neovim_colorcoder#init(data) abort
    if !exists('g:plugs["neovim-colorcoder"]')
        return -1
    endif

    let g:colorcoder_enable_filetypes = [
                \    'c',
                \    'cpp',
                \    'lua',
                \ ]
endfunction
