" ############################################################################
"
"                               gui Setttings
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

function! gui#NeovimGuiFont(size) abort

    if !has('nvim') || !exists('g:GuiLoaded')
        return -1
    endif

    let l:font_size = ( empty(a:size) ) ? '10' : a:size

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
