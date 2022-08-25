local sys = require 'sys'
local nvim = require 'neovim'

local parent = sys.data
local mkdir = require('utils.files').mkdir
local is_dir = require('utils.files').is_dir
local executable = require('utils.files').executable

local function isempty(s)
    return (s == nil or s == '') and true or false
end

local dirpaths = {
    backup = 'backupdir',
    swap = 'directory',
    undo = 'undodir',
    cache = '',
    sessions = '',
}

for dirname, dir_setting in pairs(dirpaths) do
    if not is_dir(parent .. '/' .. dirname) then
        mkdir(parent .. '/' .. dirname)
    end
    if not isempty(dir_setting) then
        vim.opt[dir_setting] = parent .. '/' .. dirname
    end
end

vim.g.lua_complete_omni = 1

vim.g.c_syntax_for_h = 0
vim.g.c_comment_strings = 1
vim.g.c_curly_error = 1
vim.g.c_no_if0 = 0

vim.g.tex_flavor = 'latex'

vim.g.terminal_scrollback_buffer_size = 100000

-- TODO: Winbar should hold current buffer information while the statusline manage repository/workspace stuff
-- winbar info ideas
--  file path
--  local git changes (add/delete/modified lines)
--  Filetype?
--  Readonly
--  unsaved changed
--  Modifiable
--  Buffer diagnostics
--
-- statusline info ideas
--  Mode
--  Spell
--  PASTE
--  Repo info: changed/untracked/staged files, stashes, current branch, pending push/pull
--  Repo diagnostics
--  Repo passed/failed tests
--  Local server status (django?)
--  Build/Compilation status
--  LSP status
--
-- Stuff that is buffer/window local but may go in the statusline since winbar maybe too small for this
--  File encoding
--  Cursor position
--  Line ending
--  Filetype?
-- Cursor context (TS or LSP)?
if vim.g.started_by_firenvim then
    vim.opt.laststatus = 0
elseif nvim.has.option 'winbar' then
    vim.opt.laststatus = 3
    vim.opt.winbar = '%=%m %f'
else
    vim.opt.laststatus = 2
end

vim.opt.shada = { '!', '/1000', "'1000", '<1000', ':1000', 's10000', 'h' }

if sys.name == 'windows' then
    vim.opt.shada:append { 'rA:', 'rB:', 'rC:', 'rC:/Temp' }
else
    vim.opt.shada:append 'r/tmp/'
end

if sys.name == 'windows' then
    vim.opt.swapfile = false
    vim.opt.backup = false
end

vim.opt.backupcopy = 'yes'
vim.opt.undofile = true

vim.opt.expandtab = true
vim.opt.shiftround = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 0
vim.opt.softtabstop = -1

vim.opt.scrollback = -1
vim.opt.updatetime = 100

vim.opt.sidescrolloff = 5
vim.opt.scrolloff = 1
vim.opt.undolevels = 10000

vim.opt.inccommand = 'split'
vim.opt.winaltkeys = 'no'
vim.opt.virtualedit = 'block'
-- vim.opt.formatoptions = 'tcqrolnj'

vim.opt.complete = { '.', 'w', 'b', 'u', 't' }
vim.opt.completeopt = { 'menu', 'menuone', 'noselect', 'noinsert' }
vim.opt.tags = { '.git/tags', './tags;', 'tags' }
vim.opt.display = { 'lastline', 'msgsep' }
vim.opt.fileformats = { 'unix', 'dos' }

vim.opt.wildmenu = true
vim.opt.wildmode = 'full'

vim.opt.pumblend = 20
vim.opt.winblend = 10

vim.opt.wildmenu = true
vim.opt.wildmode = 'full'

vim.opt.pumblend = 20
vim.opt.winblend = 10

vim.opt.showbreak = '↪\\'
vim.opt.listchars = { tab = '▸ ', trail = '•', extends = '❯', precedes = '❮' }
vim.opt.cpoptions = 'aAceFs_B'
vim.opt.shortmess:append { a = true, c = true }

vim.opt.lazyredraw = true
vim.opt.showmatch = true

vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.termguicolors = true

vim.opt.infercase = true
vim.opt.ignorecase = true
vim.opt.smartcase = false

vim.opt.smartindent = true
vim.opt.copyindent = true

vim.opt.expandtab = true

vim.opt.joinspaces = false
vim.opt.showmode = false
vim.opt.visualbell = true

vim.opt.hidden = true

vim.opt.autowrite = true
vim.opt.autowriteall = true
vim.opt.fileencoding = 'utf-8'

vim.opt.pastetoggle = '<f3>'

if vim.g.gonvim_running ~= nil then
    vim.opt.showmode = false
    vim.opt.ruler = false
else
    vim.opt.titlestring = '%t (%f)'
    vim.opt.title = true
end

vim.opt.diffopt:append {
    'vertical',
    'iwhiteall',
    'iwhiteeol',
    'indent-heuristic',
    'hiddenoff',
    'closeoff',
    'algorithm:minimal',
}

vim.opt.relativenumber = true
vim.opt.number = true
vim.opt.list = true
vim.opt.wrap = false
vim.opt.colorcolumn = '80'
vim.opt.numberwidth = 1
vim.opt.foldenable = false
vim.opt.foldmethod = 'syntax'
vim.opt.foldlevel = 99

vim.opt.signcolumn = 'auto:2'

-- TODO: Add support to read and parse local and global git ignore files
local wildignores = {
    '*.spl',
    '*.aux',
    '*.out',
    '*.o',
    '*.pyc',
    '*.gz',
    -- '*.pdf',
    '*.sw',
    '*.swp',
    '*.swap',
    '*.com',
    '*.class',
    '*.slo',
    '*.lo',
    '*.o',
    '*.oarma72smp',
    '*.oppc500',
    '*.oppc',
    '*.opp',
    '*.so',
    '*.lai',
    '*.la',
    '*.a',
    '*.pkl',
    '*cache/*',
    '*__pycache__/*',
}

local no_backup = {
    '.git/*',
    '.svn/*',
    '*.bin',
    '*.7z',
    '*.dmg',
    '*.gz',
    '*.iso',
    '*.jar',
    '*.rar',
    '*.tar',
    '*.zip',
    '*.exe',
    'TAGS',
    'tags',
    'GTAGS',
    'COMMIT_EDITMSG',
}

vim.opt.wildignore = wildignores
vim.opt.backupskip = vim.list_extend(no_backup, wildignores)

if not vim.env.SSH_CONNECTION then
    vim.opt.mouse = 'a'
    vim.opt.clipboard = { 'unnamedplus', 'unnamed' }
else
    vim.opt.mouse = ''
end

if executable 'nvr' then
    vim.env.nvr = 'nvr --servername ' .. vim.v.servername .. ' --remote-silent'
    vim.env.tnvr = 'nvr --servername ' .. vim.v.servername .. ' --remote-tab-silent'
    vim.env.vnvr = 'nvr --servername ' .. vim.v.servername .. ' -cc vsplit --remote-silent'
    vim.env.snvr = 'nvr --servername ' .. vim.v.servername .. ' -cc split --remote-silent'
end

if vim.lsp.tagfunc then
    vim.opt.tagfunc = 'v:lua.vim.lsp.tagfunc'
end

vim.opt.cscopequickfix = { 's-', 'c-', 'd-', 'i-', 't-', 'e-', 'a-', 'g-' }
