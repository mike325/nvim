scriptencoding 'utf-8'
" Airline settings
" github.com/mike325/.vim

if !has#plugin('vim-airline') || exists('g:config_airline')
    finish
endif

let g:config_airline = 1

if !has#plugin('barbar.nvim')
    let g:airline#extensions#tabline#enabled           = 1
    let g:airline#extensions#tabline#fnamemod          = ':t'
    let g:airline#extensions#tabline#close_symbol      = '×'
    let g:airline#extensions#tabline#show_tabs         = 1
    let g:airline#extensions#tabline#show_buffers      = 1
    let g:airline#extensions#tabline#show_close_button = 0
    let g:airline#extensions#tabline#show_splits       = 0
endif

let g:airline_highlighting_cache                   = 1
let g:airline_stl_path_style                       = 'short'

let g:airline#extensions#branch#format = 0

" Change to the name of the location/quickfix windows
" let g:airline#extensions#quickfix#quickfix_text = 'Quickfix'
" let g:airline#extensions#quickfix#location_text = 'Location'

if !empty($NO_COOL_FONTS) || (os#name('windows') && has('gui_running') && !has('nvim'))
    let g:airline_powerline_fonts = 0
    let g:airline_symbols_ascii = 1
else
    let g:airline_powerline_fonts = 1
    " let g:airline_symbols_ascii = 0

    let s:plugins = [
        \ 'nvimlsp',
        \ 'neomake',
        \ 'languageclient',
        \ 'lsp',
        \ 'ycm',
        \]
        " \ 'ale',
        " \ 'coc',

    for s:plugin in s:plugins
        let airline#extensions#{s:plugin}#error_symbol = '✖:'
        let airline#extensions#{s:plugin}#warning_symbol = '⚠:'
    endfor

    if !exists('g:airline_symbols')
        let g:airline_symbols = {}
    endif

    " unicode symbols
    " let g:airline_left_sep = '»'
    " let g:airline_left_sep = '▶'
    " let g:airline_right_sep = '«'
    " let g:airline_right_sep = '◀'
    " let g:airline_symbols.crypt = '🔒'
    " let g:airline_symbols.readonly = '🔒'
    " let g:airline_symbols.linenr = '☰'
    " let g:airline_symbols.linenr = '␊'
    " let g:airline_symbols.linenr = '␤'
    " let g:airline_symbols.linenr = '¶'
    " let g:airline_symbols.maxlinenr = ''
    " let g:airline_symbols.maxlinenr = '㏑'
    " let g:airline_symbols.branch = '⎇'
    " let g:airline_symbols.paste = 'ρ'
    " let g:airline_symbols.paste = 'Þ'
    " let g:airline_symbols.paste = '∥'
    " let g:airline_symbols.spell = 'Ꞩ'
    " let g:airline_symbols.notexists = 'Ɇ'
    " let g:airline_symbols.whitespace = 'Ξ'

    " " powerline symbols
    " let g:airline_left_sep = ''
    " let g:airline_left_alt_sep = ''
    " let g:airline_right_sep = ''
    " let g:airline_right_alt_sep = ''
    " let g:airline_symbols.branch = ''
    " let g:airline_symbols.readonly = ''
    " let g:airline_symbols.linenr = '☰'
    " let g:airline_symbols.maxlinenr = ''
    " let g:airline_symbols.dirty='⚡'

    " " old vim-powerline symbols
    " let g:airline_left_sep = '⮀'
    " let g:airline_left_alt_sep = '⮁'
    " let g:airline_right_sep = '⮂'
    " let g:airline_right_alt_sep = '⮃'
    " let g:airline_symbols.branch = '⭠'
    " let g:airline_symbols.readonly = '⭤'
    " let g:airline_symbols.linenr = '⭡'

endif

if !has#plugin('vim-airline-themes')
    let g:airline_theme = 'molokai'
    " let g:airline_theme = 'solarized'
    " let g:airline_theme = 'gruvbox'
endif
