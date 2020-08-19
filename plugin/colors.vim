" Colorscheme settings
" github.com/mike325/.vim

" if !has#plugin('gruvbox')
"     finish
" endif

set background=dark
set cursorline

if has#option('termguicolors')
    set termguicolors
endif

try
    if has#plugin('ayu-vim') && has('nvim')
        let g:ayucolor = 'dark'
        colorscheme ayu
    elseif has#plugin('onedark.vim')
        colorscheme onedark
    else
        colorscheme torte
        set nocursorline
    endif
catch /E185/
    colorscheme torte
    set nocursorline
endtry
