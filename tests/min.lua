vim.opt.rtp:append '.'
local nvim = require 'neovim'

vim.opt.swapfile = false

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

vim.g.show_diagnostics = true
vim.g.alternates = {}
vim.g.tests = {}
vim.g.makefiles = {}
vim.g.parsed = {}

vim.g.port = 0x8AC

-- vim.g.minimal = false
-- vim.g.bare = false

if nvim.has 'win32' then
    vim.opt.shell = 'cmd.exe'
    vim.opt.shellslash = true
end

if not vim.keymap then
    vim.keymap = require('neovim').keymap
end

vim.g.mapleader = ' '

require 'utils.ft_detect'
require 'messages'
require 'globals'
-- require('filetypes.python').pynvim_setup()

local package_plugins = vim.fn.stdpath('data'):gsub('\\', '/') .. '/site/pack/packer/start/'
vim.opt.rtp:append(package_plugins .. 'plenary.nvim/')

vim.cmd.runtime 'plugin/plenary.vim'
