" ############################################################################
"
"                               Airline settings
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

function! plugins#vim_airline#init(data) abort
    if !exists('g:plugs["vim-airline"]')
        return -1
    endif

    let g:airline#extensions#tabline#enabled           = 1
    let g:airline#extensions#tabline#fnamemod          = ':t'
    let g:airline#extensions#tabline#close_symbol      = '×'
    let g:airline#extensions#tabline#show_tabs         = 1
    let g:airline#extensions#tabline#show_buffers      = 1
    let g:airline#extensions#tabline#show_close_button = 0
    let g:airline#extensions#tabline#show_splits       = 0
    let g:airline_highlighting_cache                   = 1

    " Disable not enabled plugins
    let g:airline#extensions#xkblayout#enabled   = exists('g:plugs["xkblayout"]')      ? 1 : 0
    let g:airline#extensions#po#enabled          = exists('g:plugs["po"]')             ? 1 : 0
    let g:airline#extensions#syntastic#enabled   = exists('g:plugs["syntastic"]')      ? 1 : 0
    let g:airline#extensions#tagbar#enabled      = exists('g:plugs["tagbar"]')         ? 1 : 0
    let g:airline#extensions#csv#enabled         = exists('g:plugs["csv.vim"]')        ? 1 : 0
    let g:airline#extensions#vimagit#enabled     = exists('g:plugs["vimagit"]')        ? 1 : 0
    let g:airline#extensions#virtualenv#enabled  = exists('g:plugs["vim-virtualenv"]') ? 1 : 0
    let g:airline#extensions#eclim#enabled       = exists('g:plugs["eclim"]')          ? 1 : 0
    let g:airline#extensions#gutentags#enabled   = exists('g:plugs["vim-gutentags"]')  ? 1 : 0
    let g:airline#extensions#grepper#enabled     = exists('g:plugs["vim-grepper"]')    ? 1 : 0
    let g:airline#extensions#capslock#enabled    = exists('g:plugs["vim-capslock"]')   ? 1 : 0
    let g:airline#extensions#windowswap#enabled  = exists('g:plugs["vim-windowswap"]') ? 1 : 0
    let g:airline#extensions#obsession#enabled   = exists('g:plugs["vim-obsession"]')  ? 1 : 0
    let g:airline#extensions#taboo#enabled       = exists('g:plugs["taboo.vim"]')      ? 1 : 0
    let g:airline#extensions#ctrlspace#enabled   = exists('g:plugs["vim-ctrlspace"]')  ? 1 : 0
    let g:airline#extensions#ycm#enabled         = exists('g:plugs["YouCompleteMe"]')  ? 1 : 0
    let g:airline#extensions#vimtex#enabled      = exists('g:plugs["vimtex"]')         ? 1 : 0
    let g:airline#extensions#ale#enabled         = exists('g:plugs["ale"]')            ? 1 : 0
    let g:airline#extensions#neomake#enabled     = exists('g:plugs["neomake"]')        ? 1 : 0
    let g:airline#extensions#localsearch#enabled = exists('g:plugs["localsearch"]')    ? 1 : 0
    let g:airline#extensions#cursormode#enabled  = exists('g:plugs["vim-cursormode"]') ? 1 : 0
    let g:airline#extensions#nrrwrgn#enabled     = exists('g:plugs["NrrwRgn"]')        ? 1 : 0

    " Change to the name of the location/quickfix windows
    " let g:airline#extensions#quickfix#quickfix_text = 'Quickfix'
    " let g:airline#extensions#quickfix#location_text = 'Location'

    " Powerline fonts, check https://github.com/powerline/fonts.git for more info unicode symbols
    " let g:airline#extensions#branch#symbol = '⎇ '
    " let g:airline#extensions#whitespace#symbol = 'Ξ'
    " let g:airline_left_sep = '▶'
    " let g:airline_right_sep = '◀'
    " let g:airline_linecolumn_prefix = '␊ '
    " let g:airline_paste_symbol = 'ρ'

    if empty($NO_COOL_FONTS)
        let g:airline_powerline_fonts = 1
    endif

    if !exists('g:plugs["vim-airline-themes"]')
        let g:airline_theme = 'molokai'
        " let g:airline_theme = 'solarized'
        " let g:airline_theme = 'gruvbox'
    endif
endfunction
