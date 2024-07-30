" Colorscheme settings
" github.com/mike325/.vim

set background=dark
set cursorline

if has#option('termguicolors')
    set termguicolors
endif

if !has('nvim')
    set t_Co=256
    silent! execute 'let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"'
    silent! execute 'let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"'
endif

try
    let g:airline_theme = 'owo'

    if has#plugin('material.nvim')
        let g:material_style = 'darker'
        colorscheme material
    elseif has#plugin('tokyodark.nvim')
        let g:tokyodark_transparent_background = 0
        let g:tokyodark_enable_italic_comment = 1
        let g:tokyodark_enable_italic = 1
        " let g:tokyodark_color_gamma = '1.0'
        colorscheme tokyodark
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

        " if s:fix_colorscheme
        "     hi! Normal ctermbg=NONE guibg=NONE
        "     hi! NonText ctermbg=NONE guibg=NONE
        " endif

        set nocursorline
    endif
catch /E185/
    colorscheme torte

    " if s:fix_colorscheme
    "     hi! Normal ctermbg=NONE guibg=NONE
    "     hi! NonText ctermbg=NONE guibg=NONE
    " endif

    set nocursorline
endtry
