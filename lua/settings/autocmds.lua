-- luacheck: globals unpack vim

-- local nvim = require('nvim')
local plugs = require('nvim').plugs
local nvim_set_autocmd = require('nvim').nvim_set_autocmd

nvim_set_autocmd(
    'TermOpen',
    '*',
    'setlocal noswapfile nobackup noundofile',
    {create = true, group = 'TerminalAutocmds'}
)
nvim_set_autocmd('TermOpen', '*', 'setlocal relativenumber number nocursorline', {group = 'TerminalAutocmds'})
-- nvim_set_autocmd('TermOpen', '*', 'setlocal bufhidden=wipe', {group = 'TerminalAutocmds'})

nvim_set_autocmd('VimResized', '*', 'wincmd =', {create = true, group = 'AutoResize'})

nvim_set_autocmd(
    'BufRead',
    '*',
    'lua require("tools").last_position()',
    {create = true, group = 'LastEditPosition'}
)

if  plugs['completor.vim'] == nil then
    nvim_set_autocmd(
        {'BufNewFile', 'BufRead', 'BufEnter'},
        '*',
        "if !exists('b:trim') | let b:trim = 1 | endif",
        {create = true, group = 'CleanFile'}
    )
    nvim_set_autocmd(
        'BufWritePre',
        '*',
        'lua require("tools").clean_file()',
        {group = 'CleanFile'}
    )
end

nvim_set_autocmd(
    'BufNewFile',
    '*',
    'lua tools.file_name()',
    {create = true, group = 'Skeletons'}
)

nvim_set_autocmd(
    {'DirChanged', 'WinNew' ,'WinEnter', 'VimEnter'},
    '*',
    'lua require("tools").project_config(require"nvim".fn.deepcopy(require"nvim".v.event))',
    {create = true, group = 'ProjectConfig'}
)

nvim_set_autocmd('CmdwinEnter', '*', 'nnoremap <CR> <CR>', {create = true, group = 'LocalCR'})

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
