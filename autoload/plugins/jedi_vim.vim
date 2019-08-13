" Jedi settings
" github.com/mike325/.vim

function! plugins#jedi_vim#init(data) abort
    if  !exists('g:plugs["jedi-vim"]')
        return -1
    endif

    let g:jedi#popup_select_first       = 0
    let g:jedi#popup_on_dot             = 0
    let g:jedi#completions_command      = "<C-c>"
    let g:jedi#documentation_command    = "K"
    let g:jedi#usages_command           = "<leader>u"
    let g:jedi#goto_command             = "<leader>g"
endfunction
