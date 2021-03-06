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

let g:airline_stl_path_style     = 'short'
let g:airline_highlighting_cache = 1

let g:airline#extensions#branch#format = 0

let g:airline_mode_map = {
    \ '__'     : '-',
    \ 'c'      : 'C',
    \ 'i'      : 'I',
    \ 'ic'     : 'I',
    \ 'ix'     : 'I',
    \ 'n'      : 'N',
    \ 'multi'  : 'M',
    \ 'ni'     : 'N',
    \ 'no'     : 'N',
    \ 'R'      : 'R',
    \ 'Rv'     : 'R',
    \ 's'      : 'S',
    \ 'S'      : 'SL',
    \ ''     : 'SB',
    \ 't'      : 'T',
    \ 'v'      : 'V',
    \ 'V'      : 'VL',
    \ ''     : 'VB',
    \ }

if !empty($NO_COOL_FONTS) || (os#name('windows') && has('gui_running') && !has('nvim'))
    let g:airline_powerline_fonts = 0
    let g:airline_symbols_ascii = 1
else
    let g:airline_powerline_fonts = 1
    " let g:airline_symbols_ascii = 0
endif

let s:plugins = [
    \ 'nvimlsp',
    \ 'neomake',
    \ 'languageclient',
    \ 'lsp',
    \ 'ycm',
    \]

for s:plugin in s:plugins
    let airline#extensions#{s:plugin}#error_symbol = tools#get_icon('error').' '
    let airline#extensions#{s:plugin}#warning_symbol = tools#get_icon('warn').' '
endfor

" let g:airline#extensions#hunks#hunk_symbols = [
"     \ tools#get_icon('diff_add').' ',
"     \ tools#get_icon('diff_modified').' ',
"     \ tools#get_icon('diff_remove').' ',
"     \]

let g:airline_left_sep = tools#get_separators('arrow')['left']
let g:airline_right_sep = tools#get_separators('arrow')['right']

if !has#plugin('vim-airline-themes')
    let g:airline_theme = 'molokai'
    " let g:airline_theme = 'solarized'
    " let g:airline_theme = 'gruvbox'
endif
