" ############################################################################
"
"                                 GUI settings
"
"                                     -`
"                     ...            .o+`
"                  .+++s+   .h`.    `ooo/
"                 `+++%++  .h+++   `+oooo:
"                 +++o+++ .hhs++. `+oooooo:
"                 +s%%so%.hohhoo'  'oooooo+:
"                 `+ooohs+h+sh++`/:  ++oooo+:
"                  hh+o+hoso+h+`/++++.+++++++:
"                   `+h+++h.+ `/++++++++++++++:
"                            `/+++ooooooooooooo/`
"                           ./ooosssso++osssssso+`
"                          .oossssso-````/osssss::`
"                         -osssssso.      :ssss``to.
"                        :osssssss/  Mike  osssl   +
"                       /ossssssss/   8a   +sssslb
"                     `/ossssso+/:-        -:/+ossss'.-
"                    `+sso+:-`                 `.-/+oso:
"                   `++:.  github.com/mike325/.vim  `-/+/
"                   .`                                 `/
"
" ############################################################################

" This file could/should be linked/copied as .gvimrc for gVim configurations
" same way as init.vim must be ALWAYS linked/copied as .vimrc in $HOME
"
" Since Windows Gui is Neovim-qt (also available in Linux and MacOS), gVim options doesn't work
" For more info check https://github.com/equalsraf/neovim-qt
"
" FIX: Currently this does not fully work in Windows with different screens
" resolutions

" Make shift-insert work like in Xterm
" NOTE: please use 'p' instead of this hack
imap <S-Insert> <MiddleMouse>

if has('nvim') && exists('g:GuiLoaded')
    function! s:NeovimGuiFont(size)
        let l:font_size = ( empty(a:size) ) ? "10" : a:size

        if empty($NO_COOL_FONTS)
            try
                execute 'GuiFont! DejaVu Sans Mono for Powerline:h' . l:font_size
                " execute 'GuiFont! DsjasknkjanljdnjwejaVu Sans Mono for Powerline:h' . l:font_size
            catch
                execute 'GuiFont! Monospace:h' . l:font_size
            endtry
        else
            execute 'GuiFont! Monospace:h' . l:font_size
        endif
    endfunction

    if exists(':GuiLinespace') == 2
        GuiLinespace 1
    endif

    if exists(':GuiPopupmenu') == 2
        GuiPopupmenu 0
    endif

    if exists(':GuiTabline') == 2
        GuiTabline 0
    endif

    if exists('*GuiWindowMaximized')
        call GuiWindowMaximized(1)
    endif

    if exists('*GuiMousehide')
        call GuiMousehide(1)
    endif

    if exists(':GuiFont') == 2
        call s:NeovimGuiFont(10)
    endif

    command! -nargs=? Font call s:NeovimGuiFont(<q-args>)

elseif has("gui_running")
    set guioptions-=m  " no menu
    set guioptions-=T  " no toolbar
    set guioptions-=L  " remove left-hand scroll bar in vsplit
    set guioptions-=l  " remove left-hand scroll bar
    set guioptions-=r  " remove right-hand scroll bar
    set guioptions-=R  " remove right-hand scroll bar vsplit
    set guioptions-=b  " remove bottom scroll bar

    " Windows gVim fonts
    " TODO: Add Linux gui fonts (I don't use gVim in Linux, but may be useful)
    if os#name('windows')
        set guifont=DejaVu_Sans_Mono_for_Powerline:h11,DejaVu_Sans_Mono:h11
    endif
endif
