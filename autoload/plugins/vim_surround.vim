scriptencoding 'utf-8'

" Surround Setttings
" github.com/mike325/.vim

function! plugins#vim_surround#init(data) abort
    if !exists('g:plugs["vim-surround"]')
        return -1
    endif

    let g:surround_{char2nr("¿")} = "¿\r?"
    let g:surround_{char2nr("?")} = "¿\r?"
    let g:surround_{char2nr("¡")} = "¡\r!"
    let g:surround_{char2nr("!")} = "¡\r!"
    let g:surround_{char2nr(";")} = ":\r:"
    let g:surround_{char2nr(":")} = ":\r:"
    let g:surround_{char2nr('q')} = "``\r''"

endfunction
