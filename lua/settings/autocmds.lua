-- luacheck: globals unpack vim

local nvim = require('nvim')
local plugs = require('nvim').plugs
local nvim_set_autocmd = require('nvim').nvim_set_autocmd

nvim_set_autocmd('TermOpen', '*', 'setlocal noswapfile nobackup noundofile', {create = true, group = 'TerminalAutocmds'})
nvim_set_autocmd('TermOpen', '*', 'setlocal relativenumber number nocursorline', {create = true, group = 'TerminalAutocmds'})
nvim_set_autocmd('TermOpen', '*', 'setlocal bufhidden=wipe', {create = true, group = 'TerminalAutocmds'})

nvim_set_autocmd('VimResized', '*', 'wincmd =', {create = true, group = 'AutoResize'})

nvim_set_autocmd('BufRead', '*', 'lua require("tools").last_position()', {create = true, group = 'LastEditPosition'})

if  plugs['completor.vim'] == nil then
    nvim_set_autocmd(
        {'BufNewFile', 'BufRead', 'BufEnter'},
        '*',
        "if !exists('b:trim') | let b:trim = 1 | endif",
        {create = true, group = 'CleanFile'}
    )
    nvim_set_autocmd('BufWritePre', '*', 'call autocmd#CleanFile()', {create = true, group = 'CleanFile'})
end

nvim_set_autocmd('BufNewFile', '*', 'call autocmd#FileName()', {create = true, group = 'Skeletons'})

nvim_set_autocmd(
    {'DirChanged', 'WinNew' ,'WinEnter', 'VimEnter', 'SessionLoadPost'},
    '*',
    'call autocmd#SetProjectConfigs()',
    {create = true, group = 'ProjectConfig'}
)

nvim_set_autocmd('CmdwinEnter', '*', 'nnoremap <CR> <CR>', {create = true, group = 'LocalCR'})

nvim_set_autocmd(
    {'BufEnter','BufReadPost'},
    '__LanguageClient__',
    'nnoremap <silent> <buffer> q :q!<CR>',
    {create = true, group = 'QuickQuit'}
)
nvim_set_autocmd(
    {'BufEnter','BufWinEnter'},
    '*',
    'if &previewwindow | nnoremap <silent> <buffer> q :q!<CR> | endif',
    {create = true, group = 'QuickQuit'}
)
nvim_set_autocmd(
    'TermOpen',
    '*',
    'nnoremap <silent> <buffer> q :q!<CR>',
    {create = true, group = 'QuickQuit'}
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
