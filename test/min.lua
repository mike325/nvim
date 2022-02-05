local nvim = require 'neovim'

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
end

if not vim.keymap then
    vim.keymap = require('neovim').keymap
end

vim.g.do_filetype_lua = 1
if nvim.has { 0, 7 } then
    vim.g.did_load_filetypes = 0
end

vim.g.mapleader = ' '

require 'filetypes.detect'
require 'messages'
require 'globals'
require('filetypes.python').pynvim_setup()

-- local is_min = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
-- local is_bare = vim.env.VIM_BARE ~= nil or vim.g.bare ~= nil

-- require'storage'
require('utils.functions').get_ssh_hosts()

vim.cmd [[packadd! cfilter]]
vim.cmd [[packadd! matchit]]
