scriptencoding 'utf-8'
" IndentLine settings
" github.com/mike325/.vim

if !has#plugin('indentLine') || exists('g:config_indentline')
    finish
endif

let g:config_indentline = 1

" Show indentation lines for space indented code
" If you use code tab indention you can set this
" set list lcs=tab:\┊\
" Check plugin/settings.vim for more details

" nnoremap tdi :IndentLinesToggle<CR>

let g:indentLine_char = empty($NO_COOL_FONTS) ? '┊' : '│'

" Set the inline characters for each indent
" let g:indentLine_char_list = ['|', '¦', '┆', '┊']

let g:indentLine_color_gui       = '#DDC188'
let g:indentLine_color_term      = 214
let g:indentLine_enabled         = 1
let g:indentLine_setColors       = 1

" let g:indentLine_leadingSpaceChar = '*'

let g:indentLine_fileTypeExclude = [
    \   'text',
    \   'conf',
    \   'markdown',
    \   'help',
    \   'man',
    \   'git',
    \   'log',
    \   '',
    \]

let g:indentLine_bufTypeExclude = [
    \   'terminal',
    \   'help',
    \]

let g:indentLine_bufNameExclude = [
    \   '',
    \   '*.org',
    \   '*.log',
    \   'COMMIT_EDITMSG',
    \   'NERD_tree.*',
    \   'term://*',
    \   'man://*',
    \]
