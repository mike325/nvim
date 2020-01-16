" Nvim Setttings
" github.com/mike325/.vim

" let s:load_remotes = 0

function! nvim#updateremoteplugins(info) abort
    if has('nvim')
        let s:load_remotes = 1
    endif
endfunction

function! nvim#init() abort
    if !has('nvim')
        return -1
    endif
    " Disable some vi compatibility
    if !exists('g:plugs["traces.vim"]')
        " Live substitute preview
        set inccommand=split
    endif

    if executable('nvr')
        " Add Neovim remote utility, this allow us to open buffers from the :terminal cmd
        let $nvr = 'nvr --remote-silent'
        let $tnvr = 'nvr --remote-tab-silent'
        let $vnvr = 'nvr -cc vsplit --remote-silent'
        let $snvr = 'nvr -cc split --remote-silent'
    endif

    let g:terminal_scrollback_buffer_size = 100000

    if has('nvim-0.2')
        set signcolumn=auto
        set cpoptions-=_
    endif

    if exists('g:gonvim_running')
        " Use Gonvim UI instead of (Neo)vim native GUI/TUI

        " set laststatus=0
        set noshowmode
        set noruler

        if exists('g:plugs["gonvim-fuzzy"]')
            let g:gonvim_fuzzy_ag_cmd = tools#grep('rg', 'grepprg')
        endif

    else
        set titlestring=%t\ (%f)
        set title          " Set window title
    endif

endfunction
