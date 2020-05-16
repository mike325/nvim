" Colorscheme settings
" github.com/mike325/.vim

" if !exists('g:plugs["gruvbox"]')
"     finish
" endif

set background=dark
set cursorline

if has('termguicolors')
    set termguicolors
endif

try
    if exists('g:plugs["ayu-vim"]') && has('nvim')
        let g:ayucolor = 'dark'
        colorscheme ayu
    elseif exists('g:plugs["onedark.vim"]')
        colorscheme onedark
    else
        colorscheme torte
        set nocursorline
    endif
catch /E185/
    colorscheme torte
    set nocursorline
endtry
