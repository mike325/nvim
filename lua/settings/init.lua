local nvim  = require'nvim'
local sys   = require'sys'

-- local select_grep = require'tools'.helpers.select_grep
local set_grep = require'tools'.helpers.set_grep

local parent     = sys.data
local plugins    = nvim.plugins
local mkdir      = require'tools'.files.mkdir
local is_dir     = require'tools'.files.is_dir
local executable = require'tools'.files.executable

local function isempty(s)
    return (s == nil or s == '') and true or false
end

local dirpaths = {
    backup   = 'backupdir',
    swap     = 'directory',
    undo     = 'undodir',
    cache    = '',
    sessions = '',
}

for dirname,dir_setting in pairs(dirpaths) do
    if not is_dir(parent .. '/' .. dirname) then
        mkdir(parent .. '/' .. dirname)
    end

    if not isempty(dir_setting) then
        nvim.o[dir_setting] = parent .. '/' .. dirname
    end
end

nvim.g.lua_complete_omni = 1

nvim.g.c_syntax_for_h = 0
nvim.g.c_comment_strings = 1
nvim.g.c_curly_error = 1
nvim.g.c_no_if0 = 0

nvim.g.terminal_scrollback_buffer_size = 100000

if nvim.g.started_by_firenvim ~= nil then
    nvim.o.laststatus = 0
end

nvim.o.shada =  "!,/1000,'1000,<1000,:1000,s10000,h"

if sys.name == 'windows' then
    nvim.o.shada = nvim.o.shada .. ",rA:,rB:,rC:/Temp/"
else
    nvim.o.shada = nvim.o.shada .. ",r/tmp/"
end

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
nvim.o.completeopt = 'menuone,noselect,noinsert'
nvim.o.tags        = '.git/tags,./tags;,tags'
nvim.o.display     = 'lastline,msgsep'
nvim.o.fileformats = 'unix,dos'

nvim.o.wildmenu = true
nvim.o.wildmode = 'full'

nvim.o.pumblend = 20
nvim.o.winblend = 10

nvim.o.showbreak      = '↪\\'
nvim.o.listchars      = 'tab:▸ ,trail:•,extends:❯,precedes:❮'
nvim.o.cpoptions      = 'aAceFs_B'

nvim.o.lazyredraw = true
nvim.o.showmatch  = true

nvim.o.splitright = true
nvim.o.splitbelow = true

nvim.o.backup   = true
nvim.o.undofile = true

nvim.o.termguicolors = true

nvim.o.infercase  = true
nvim.o.ignorecase = true
nvim.o.smartcase  = false

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

nvim.o.pastetoggle = '<f3>'

if nvim.g.gonvim_running ~= nil then
    nvim.o.showmode = false
    nvim.o.ruler    = false
else
    nvim.o.titlestring = '%t (%f)'
    nvim.o.title       = true
end

-- Default should be internal,filler,closeoff
nvim.o.diffopt = nvim.o.diffopt .. ',vertical,iwhiteall,iwhiteeol,indent-heuristic,algorithm:patience,hiddenoff'

set_grep(false, false)

if plugins['vim-airline'] == nil then
    nvim.o.statusline = [[%< [%f]%=%-5.(%y%r%m%w%q%) %-14.(%l,%c%V%) %P ]]
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

if executable('nvr') then
    nvim.env.nvr  = 'nvr --servername '.. nvim.v.servername ..' --remote-silent'
    nvim.env.tnvr = 'nvr --servername '.. nvim.v.servername ..' --remote-tab-silent'
    nvim.env.vnvr = 'nvr --servername '.. nvim.v.servername ..' -cc vsplit --remote-silent'
    nvim.env.snvr = 'nvr --servername '.. nvim.v.servername ..' -cc split --remote-silent'
end
