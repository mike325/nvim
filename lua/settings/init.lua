local nvim = require('nvim')
local api = vim.api

local parent      = require('sys').data
local mkdir       = require('nvim').fn.mkdir
local isdirectory = require('nvim').fn.isdirectory

local function isempty(s)
    return s == nil or s == ''
end

local dirpaths = {
    backup   = 'backupdir',
    swap     = 'directory',
    undo     = 'undodir',
    cache    = '',
    sessions = '',
}

for dirname,dir_setting in pairs(dirpaths) do
    if not isdirectory(parent .. '/' .. dirname) then
        mkdir(parent .. '/' .. dirname, 'p')
    end

    if not isempty(dir_setting) then
        nvim.option[dir_setting] = parent .. '/' .. dirname
    end
end

nvim.option.shada =  "!,/1000,'1000,<1000,:1000,s10000,h"

nvim.option.backup     = true
nvim.option.undofile   = true
nvim.option.signcolumn = 'auto'
nvim.option.inccommand = 'split'

nvim.g.terminal_scrollback_buffer_size = 100000

if nvim.g.gonvim_running ~= nil then
    nvim.option.showmode = false
    nvim.option.ruler    = false
else
    nvim.option.titlestring = '%t (%f)'
    nvim.option.title       = true
end

local wildignores = {
    '*.spl',
    '*.aux',
    '*.out',
    '*.o',
    '*.pyc',
    '*.gz',
    '*.pdf',
    '*.sw',
    '*.swp',
    '*.swap',
    '*.com',
    '*.exe',
    '*.so',
    '*/cache/*',
    '*/__pycache__/*',
}

local no_backup = {
    '.git/*',
    '.svn/*',
    '.xml',
    '*.log',
    '*.bin',
    '*.7z',
    '*.dmg',
    '*.gz',
    '*.iso',
    '*.jar',
    '*.rar',
    '*.tar',
    '*.zip',
    'TAGS',
    'tags',
    'GTAGS',
    'COMMIT_EDITMSG',
}

nvim.option.wildignore =  table.concat(wildignores, ',')
nvim.option.backupskip =  table.concat(no_backup, ',') .. ',' .. table.concat(wildignores, ',')

if nvim.env.SSH_CONNECTION == nil then
    nvim.option.clipboard = 'unnamedplus,unnamed'
end
