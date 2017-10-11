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

" This file could/should be linked/copied as .gvimrc in gVim configurations
" same way as init.vim must be ALWAYS linked/copied as .vimrc in $HOME
"
" Since Windows Gui is Neovim-qt (also available in Linux and MacOS), gVim options doesn't work
" For more info check https://github.com/equalsraf/neovim-qt
"
" FIX: Currently this not fully work in Windows with different screens
" resolutions
if has('nvim') && exists('g:GuiLoaded')
    function! NeovimGuiSetup()
        GuiLinespace 1
        call GuiWindowMaximized(1)
        GuiFont Monospace:h11
    endfunction

    GuiLinespace 1
    call GuiWindowMaximized(1)
    GuiFont Monospace:h11
    " call NeovimGuiSetup()
    " augroup neovimguiattached
    "     autocmd!
    "     autocmd VimEnter * call NeovimGuiSetup()
    " augroup end

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
    if has("win32") || has("win64")
        set guifont=DejaVu_Sans_Mono_for_Powerline:h11,DejaVu_Sans_Mono:h11
    else
        " Make shift-insert work like in Xterm
        map <S-Insert> <MiddleMouse>
        map! <S-Insert> <MiddleMouse>
    endif
endif
