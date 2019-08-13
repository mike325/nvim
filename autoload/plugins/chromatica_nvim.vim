" Chromatica Setttings
" github.com/mike325/.vim

function! plugins#chromatica_nvim#init(data) abort
    if !exists('g:plugs["chromatica.nvim"]')
        return -1
    endif

    let g:chromatica#libclang_path     = vars#libclang()
    let g:chromatica#enable_at_startup = empty(vars#libclang()) ? 0 : 1
endfunction
