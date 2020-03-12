local nvim  = require('nvim')

-- local api = nvim.api

local sys   = require('sys')
local plugs = require('nvim').plugs

local parent      = require('sys').data
local mkdir       = require('nvim').fn.mkdir
local isdirectory = require('nvim').fn.isdirectory

local tools = require('tools')

local function isempty(s)
    return (s == nil or s == '') and 1 or 0
end

local dirpaths = {
    backup   = 'backupdir',
    swap     = 'directory',
    undo     = 'undodir',
    cache    = '',
    sessions = '',
}

for dirname,dir_setting in pairs(dirpaths) do
    if isdirectory(parent .. '/' .. dirname) == 0 then
        mkdir(parent .. '/' .. dirname, 'p')
    end

    if isempty(dir_setting) == 0 then
        nvim.o[dir_setting] = parent .. '/' .. dirname
    end
end

nvim.g.lua_complete_omni = 1
nvim.g.c_syntax_for_h = 1
nvim.g.terminal_scrollback_buffer_size = 100000

if nvim.g.started_by_firenvim ~= nil then
    nvim.o.laststatus = 0
end

nvim.o.shada =  "!,/1000,'1000,<1000,:1000,s10000,h"

nvim.o.expandtab   = true
nvim.o.shiftround  = true
nvim.o.tabstop     = 4
nvim.o.shiftwidth  = 0
nvim.o.softtabstop = -1

nvim.o.scrollback  = -1
nvim.o.updatetime  = 1000

nvim.o.sidescrolloff = 5
nvim.o.scrolloff     = 1
nvim.o.undolevels    = 10000

nvim.o.inccommand    = 'split'
nvim.o.winaltkeys    = 'no'
nvim.o.virtualedit   = 'block'
nvim.o.formatoptions = 'tcqrolnj'
nvim.o.backupcopy    = 'yes'

nvim.o.complete    = '.,w,b,u,t'
nvim.o.completeopt = 'menuone,noselect'
nvim.o.tags        = '.git/tags,./tags;,tags'
nvim.o.display     = 'lastline,msgsep'
nvim.o.fileformats = 'unix,dos'

nvim.o.wildmenu = true
nvim.o.wildmode = 'full'

nvim.o.pumblend = 20
nvim.o.winblend = 10

nvim.o.showbreak      = '↪\\'
nvim.o.listchars      = 'tab:▸ ,trail:•,extends:❯,precedes:❮'
nvim.o.sessionoptions = 'buffers,curdir,folds,globals,localoptions,options,resize,tabpages,winpos,winsize'
nvim.o.cpoptions      = 'aAceFs_B'

if sys.name == 'windows' then
    nvim.o.sessionoptions = nvim.o.sessionoptions .. ',slash,unix'
end

nvim.o.lazyredraw = true
nvim.o.showmatch  = true

nvim.o.splitright = true
nvim.o.splitbelow = true

nvim.o.backup   = true
nvim.o.undofile = true

nvim.o.termguicolors = true

nvim.o.infercase  = true
nvim.o.ignorecase = true

nvim.o.smartindent = true
nvim.o.copyindent  = true

nvim.o.expandtab = true

nvim.o.joinspaces = false
nvim.o.showmode   = false
nvim.o.visualbell = true
nvim.o.shiftround = true

nvim.o.hidden = true

nvim.o.autowrite    = true
nvim.o.autowriteall = true
nvim.o.fileencoding = 'utf-8'

if nvim.g.gonvim_running ~= nil then
    nvim.o.showmode = false
    nvim.o.ruler    = false
else
    nvim.o.titlestring = '%t (%f)'
    nvim.o.title       = true
end

-- Default should be internal,filler,closeoff
nvim.o.diffopt = nvim.o.diffopt .. ',vertical,iwhiteall,iwhiteeol,indent-heuristic,algorithm:minimal,hiddenoff'

nvim.o.grepprg = tools.select_grep(false)
nvim.o.grepformat = tools.select_grep(false, 'grepformat')

if plugs['vim-fugitive'] ~= nil and plugs['vim-airline'] == nil then
    nvim.o.statusline = '%<%f %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%) %P'
end

-- Window options
-- Use set to modify global and window value
nvim.command('set breakindent')
nvim.command('set relativenumber')
nvim.command('set number')
nvim.command('set list')
nvim.command('set nowrap')
nvim.command('set nofoldenable')
nvim.command('set colorcolumn=80')
nvim.command('set foldmethod=syntax')
nvim.command('set signcolumn=auto')
nvim.command('set numberwidth=1')
nvim.command('set foldlevel=99')

-- Changes in nvim master
-- nvim.wo.foldcolumn     = 'auto'

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

nvim.o.wildignore =  table.concat(wildignores, ',')
nvim.o.backupskip =  table.concat(no_backup, ',') .. ',' .. table.concat(wildignores, ',')

if nvim.env.SSH_CONNECTION == nil then
    nvim.o.mouse     = 'a'
    nvim.o.clipboard = 'unnamedplus,unnamed'
else
    nvim.o.mouse     = ''
end

if nvim.fn.executable('nvr') == 1 then
    nvim.env.nvr  = 'nvr --servername '.. nvim.v.servername ..' --remote-silent'
    nvim.env.tnvr = 'nvr --servername '.. nvim.v.servername ..' --remote-tab-silent'
    nvim.env.vnvr = 'nvr --servername '.. nvim.v.servername ..' -cc vsplit --remote-silent'
    nvim.env.snvr = 'nvr --servername '.. nvim.v.servername ..' -cc split --remote-silent'
end
