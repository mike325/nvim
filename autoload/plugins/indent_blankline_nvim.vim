scriptencoding 'utf-8'
" indent_blankline_nvim Settings
" github.com/mike325/.vim

if !has#plugin('indent-blankline.nvim') || exists('g:config_indent_blankline')
    finish
endif

let g:config_indent_blankline = 1

let g:indent_blankline_use_treesitter = has#plugin('nvim-treesitter')
" let g:indent_blankline_show_current_context = has#plugin('nvim-treesitter')
let g:indent_blankline_show_first_indent_level = v:false
let g:indent_blankline_indent_level = 4

let g:indent_blankline_filetype_exclude = [
    \   'text',
    \   'conf',
    \   'markdown',
    \   'help',
    \   'man',
    \   'git',
    \   'log',
    \   'Telescope',
    \   'TelescopePrompt',
    \]

let g:indent_blankline_buftype_exclude = [
    \   'terminal',
    \   'help',
    \]

let g:indent_blankline_bufname_exclude = [
    \   '',
    \   '.*\.org',
    \   '.*\.log',
    \   'COMMIT_EDITMSG',
    \   'NERD_tree.*',
    \   'term://.*',
    \   'man://.*',
    \]
