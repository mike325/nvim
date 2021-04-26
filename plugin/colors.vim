" Colorscheme settings
" github.com/mike325/.vim

set background=dark
set cursorline

if has#option('termguicolors')
    set termguicolors
endif

if !has('nvim')
    set t_Co=256
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

try
    let g:airline_theme = 'owo'

    if has#plugin('material.nvim')
        let g:material_style = 'darker'
        colorscheme material
    elseif has#plugin('zephyr-nvim')
        colorscheme zephyr
    elseif has#plugin('sonokai')
        let g:sonokai_better_performance = 1
        let g:sonokai_style = 'shusia'
        let g:sonokai_enable_italic = 1
        let g:sonokai_disable_italic_comment = 1
        let g:sonokai_diagnostic_line_highlight = 1
        colorscheme sonokai
    elseif has#plugin('ayu-vim') && has('nvim')
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
