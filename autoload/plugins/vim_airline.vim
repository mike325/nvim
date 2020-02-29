scriptencoding 'utf-8'
" Airline settings
" github.com/mike325/.vim

if !exists('g:plugs["vim-airline"]') && exists('g:config_airline')
    finish
endif

let g:config_airline = 1

let g:airline#extensions#tabline#enabled           = 1
let g:airline#extensions#tabline#fnamemod          = ':t'
let g:airline#extensions#tabline#close_symbol      = '×'
let g:airline#extensions#tabline#show_tabs         = 1
let g:airline#extensions#tabline#show_buffers      = 1
let g:airline#extensions#tabline#show_close_button = 0
let g:airline#extensions#tabline#show_splits       = 0
let g:airline_highlighting_cache                   = 1

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

if !empty($NO_COOL_FONTS) || (os#name('windows') && has('gui_running') && !has('nvim'))
    let g:airline_powerline_fonts = 0
else
    let g:airline_powerline_fonts = 1
endif

if !exists('g:plugs["vim-airline-themes"]')
    let g:airline_theme = 'molokai'
    " let g:airline_theme = 'solarized'
    " let g:airline_theme = 'gruvbox'
endif
