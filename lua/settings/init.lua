local api = vim.api

local sys   = require('sys')
local nvim  = require('nvim')
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
        nvim.option[dir_setting] = parent .. '/' .. dirname
    end
end

nvim.g.lua_complete_omni = 1
nvim.g.c_syntax_for_h = 1
nvim.g.terminal_scrollback_buffer_size = 100000

nvim.option.shada =  "!,/1000,'1000,<1000,:1000,s10000,h"

nvim.option.expandtab   = true
nvim.option.shiftround  = true
nvim.option.tabstop     = 4
nvim.option.shiftwidth  = 0
nvim.option.softtabstop = -1

nvim.option.scrollback  = -1
nvim.option.updatetime  = 1000

nvim.option.sidescrolloff = 5
nvim.option.scrolloff     = 1
nvim.option.undolevels    = 10000

nvim.option.inccommand    = 'split'
nvim.option.winaltkeys    = 'no'
nvim.option.virtualedit   = 'block'
nvim.option.formatoptions = 'tcqrolnj'
nvim.option.backupcopy    = 'yes'

nvim.option.complete    = '.,w,b,u,t'
nvim.option.completeopt = 'menuone,noselect'
nvim.option.tags        = '.git/tags,./tags;,tags'
nvim.option.display     = 'lastline,msgsep'
nvim.option.fileformats = 'unix,dos'

nvim.option.wildmenu = true
nvim.option.wildmode = 'full'

nvim.option.pumblend = 20

nvim.option.showbreak      = '↪\\'
nvim.option.listchars      = 'tab:▸ ,trail:•,extends:❯,precedes:❮'
nvim.option.sessionoptions = 'buffers,curdir,folds,globals,localoptions,options,resize,tabpages,winpos,winsize'
nvim.option.cpoptions      = 'aAceFs_B'

if sys.name == 'windows' then
    nvim.option.sessionoptions = nvim.option.sessionoptions .. ',slash,unix'
end

nvim.option.lazyredraw = true
nvim.option.showmatch  = true

nvim.option.splitright = true
nvim.option.splitbelow = true

nvim.option.backup   = true
nvim.option.undofile = true

nvim.option.termguicolors = true

nvim.option.infercase  = true
nvim.option.ignorecase = true

nvim.option.smartindent = true
nvim.option.copyindent  = true

nvim.option.expandtab = true

nvim.option.joinspaces = false
nvim.option.showmode   = false
nvim.option.visualbell = true
nvim.option.shiftround = true

nvim.option.hidden = true

nvim.option.autowrite    = true
nvim.option.autowriteall = true
nvim.option.fileencoding = 'utf-8'

if nvim.g.gonvim_running ~= nil then
    nvim.option.showmode = false
    nvim.option.ruler    = false
else
    nvim.option.titlestring = '%t (%f)'
    nvim.option.title       = true
end

-- Default should be internal,filler,closeoff
if nvim.has('nvim-0.3.3') then
    nvim.option.diffopt = nvim.option.diffopt .. ',vertical,iwhiteall,iwhiteeol,indent-heuristic,algorithm:minimal,hiddenoff'
else
    nvim.option.diffopt = 'vertical,iwhite'
end

nvim.option.grepprg = tools.select_grep(false)
nvim.option.grepformat = tools.select_grep(false, 'grepformat')

if plugs['vim-fugitive'] ~= nil and plugs['vim-airline'] == nil then
    nvim.option.statusline = '%<%f %h%m%r%{FugitiveStatusline()}%=%-14.(%l,%c%V%) %P'
end

-- Window options

nvim.wo.breakindent    = true
nvim.wo.relativenumber = true
nvim.wo.number         = true
nvim.wo.list           = true
nvim.wo.wrap           = false
nvim.wo.foldenable     = false
nvim.wo.colorcolumn    = '80'
nvim.wo.foldmethod     = 'syntax'
nvim.wo.signcolumn     = 'auto'
nvim.wo.numberwidth    = 1
nvim.wo.foldlevel      = 99
nvim.wo.foldcolumn     = 0

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
    nvim.option.mouse     = 'a'
    nvim.option.clipboard = 'unnamedplus,unnamed'
else
    nvim.option.mouse     = ''
end
