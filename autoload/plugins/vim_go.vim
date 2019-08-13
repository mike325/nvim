" Vim Go settings
" github.com/mike325/.vim

function! plugins#vim_go#init(data) abort
    if !exists('g:plugs["vim-go"]')
        return -1
    endif

    let g:go_textobj_enabled = 1

    let g:go_auto_sameids               = 1
    let g:go_highlight_functions        = 1
    let g:go_highlight_methods          = 1
    let g:go_highlight_fields           = 1
    let g:go_gocode_unimported_packages = 1

    " NOTE: Disable this if Vim becomes slow while editing Go files
    let g:go_highlight_types            = 1
    let g:go_highlight_operators        = 1

    " There's no need to have 2 autoforma running
    if exists('g:plugs["vim-autoformat"]')
        let g:go_fmt_autosave = 0
    endif

    " YouCompleteMe already define <C-]> mappings
    if exists('g:plugs["YouCompleteMe"]')
        let g:go_def_mapping_enabled = 0
    endif

    if executable('gopls')
        let g:go_def_mode  = 'gopls'
        let g:go_info_mode = 'gopls'
    endif

endfunction

