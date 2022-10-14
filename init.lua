-- luacheck: max line length 170
local nvim = require 'neovim'

if not nvim.has { 0, 7 } then
    vim.api.nvim_err_writeln 'Neovim version is too old!! please use the legacy branch or the nvim-0.6 tag'
end

vim.g.loaded_2html_plugin = 1
vim.g.loaded_gzip = 1
vim.g.loaded_rrhelper = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_zipPlugin = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_tarPlugin = 1
vim.g.loaded_vimballPlugin = 1

vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0

if nvim.has 'win32' then
    vim.opt.shell = 'cmd.exe'
    -- vim.opt.shell = 'powershell'
    -- vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    -- vim.opt.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    -- vim.opt.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    -- vim.opt.shellquote = ''
    -- vim.opt.shellxquote = ''

    vim.opt.shellslash = false
end

if not vim.keymap then
    vim.keymap = nvim.keymap
end

vim.g.mapleader = ' '

require 'utils.ft_detect'
require 'messages'
require 'globals'
require('filetypes.python').pynvim_setup()

local is_min = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
local is_bare = vim.env.VIM_BARE ~= nil or vim.g.bare ~= nil

local host_plugins = vim.fn.stdpath('data'):gsub('\\', '/') .. '/site/pack/host'
if vim.fn.isdirectory(host_plugins) == 0 then
    vim.fn.mkdir(host_plugins .. '/opt/host', 'p')
    vim.fn.mkdir(host_plugins .. '/start/host', 'p')
end

if nvim.executable 'git' and not is_bare then
    if vim.fn.filereadable './plugin/packer_compiled.lua' ~= 1 then
        require 'setup'()
        pcall(require, 'plugins')
    end
elseif not is_min and not is_bare then
    vim.notify('Missing git! cannot install plugins', 'WARN', { title = 'Nvim Setup' })
end

-- require'storage'
require('utils.functions').get_ssh_hosts()

-- NOTE: Compatibility layer with nvim-0.8
if not vim.fs then
    vim.fs = {
        basename = require('utils.files').basename,
        normalize = require('utils.files').normalize_path, -- NOTE: These functions are not exactly equivalent
        dir = require('utils.files').dir,
        dirname = require('utils.files').dirname,
        parents = require('utils.files').parents,
        -- find = require'utils.files'.find,
    }
end

vim.cmd [[packadd! cfilter]]
vim.cmd [[packadd! matchit]]
vim.cmd [[packadd! termdebug]]
