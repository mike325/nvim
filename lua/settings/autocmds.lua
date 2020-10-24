-- luacheck: globals unpack vim

local has              = require'nvim'.has
local plugins          = require'nvim'.plugins
local nvim_set_autocmd = require'nvim'.nvim_set_autocmd

local sys = require'sys'

-- nvim_set_autocmd(
--     'TermOpen',
--     '*',
--     'setlocal bufhidden=wipe',
--     {group = 'TerminalAutocmds'}
-- )

nvim_set_autocmd(
    'TermOpen',
    '*',
    'setlocal noswapfile nobackup noundofile',
    {create = true, group = 'TerminalAutocmds'}
)

nvim_set_autocmd(
    'TermOpen',
    '*',
    'setlocal relativenumber number nocursorline',
    {group = 'TerminalAutocmds'}
)

nvim_set_autocmd(
    'VimResized',
    '*',
    'wincmd =',
    {create = true, group = 'AutoResize'}
)

nvim_set_autocmd(
    'BufRead',
    '*',
    'lua require"tools".last_position()',
    {create = true, group = 'LastEditPosition'}
)

nvim_set_autocmd(
    'BufNewFile',
    '*',
    'lua require"tools".file_name()',
    {create = true, group = 'Skeletons'}
)

nvim_set_autocmd(
    {'DirChanged', 'BufNewFile', 'BufReadPre', 'BufEnter', 'VimEnter'},
    '*',
    'lua require"tools.helpers".project_config(require"nvim".fn.deepcopy(require"nvim".v.event))',
    {create = true, group = 'ProjectConfig'}
)

nvim_set_autocmd(
    'CmdwinEnter',
    '*',
    'nnoremap <CR> <CR>',
    {create = true, group = 'LocalCR'}
)

nvim_set_autocmd(
    {'BufEnter','BufReadPost'},
    '__LanguageClient__',
    'nnoremap <silent> <nowait> <buffer> q :q!<CR>',
    {create = true, group = 'QuickQuit'}
)
nvim_set_autocmd(
    {'BufEnter','BufWinEnter'},
    '*',
    'if &previewwindow | nnoremap <silent> <nowait> <buffer> q :q!<CR>| endif',
    {group = 'QuickQuit'}
)
nvim_set_autocmd(
    'TermOpen',
    '*',
    'nnoremap <silent><nowait><buffer> q :q!<CR>',
    {group = 'QuickQuit'}
)

nvim_set_autocmd(
    {'BufNewFile', 'BufReadPre', 'BufEnter'},
    '/tmp/*',
    'setlocal noswapfile nobackup noundofile',
    {create = true, group = 'DisableTemps'}
)

nvim_set_autocmd(
    {'InsertLeave', 'CompleteDone'},
    '*',
    'if pumvisible() == 0 | pclose | endif',
    {create = true, group = 'CloseMenu'}
)

if has('nvim-0.5') then
    nvim_set_autocmd(
        'TextYankPost',
        '*',
        [[silent! lua require'vim.highlight'.on_yank("IncSearch", 3000)]],
        {create = true, group = 'YankHL'}
    )
end

if plugins['completor.vim'] == nil then
    nvim_set_autocmd(
        {'BufNewFile', 'BufReadPre', 'BufEnter'},
        '*',
        "if !exists('b:trim') | let b:trim = v:true | endif",
        {create = true, group = 'CleanFile'}
    )

    nvim_set_autocmd(
        'BufWritePre',
        '*',
        'lua require"tools".clean_file()',
        {group = 'CleanFile'}
    )
end
