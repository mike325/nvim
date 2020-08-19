" GUI settings
" github.com/mike325/.vim

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

    if has#cmd('GuiLinespace') == 2
        GuiLinespace 1
    endif

    if has#cmd('GuiPopupmenu') == 2
        GuiPopupmenu 0
    endif

    if has#cmd('GuiTabline') == 2
        GuiTabline 0
    endif

    if has#func('GuiWindowMaximized')
        call GuiWindowMaximized(1)
    endif

    if has#func('GuiMousehide')
        call GuiMousehide(1)
    endif

    if has#cmd('GuiFont') == 2
        call gui#NeovimGuiFont(10)
    endif

    command! -nargs=? Font call gui#NeovimGuiFont(<q-args>)

elseif has('veonim')
    set linespace=2
elseif has('gui_running')
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
