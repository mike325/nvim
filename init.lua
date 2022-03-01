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
    vim.keymap = nvim.keymap
end

vim.g.do_filetype_lua = 1
if nvim.has { 0, 7 } then
    vim.g.did_load_filetypes = 0
end

vim.g.mapleader = ' '

require 'utils.ft_detect'
require 'messages'
require 'globals'
require('filetypes.python').pynvim_setup()

local is_min = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
local is_bare = vim.env.VIM_BARE ~= nil or vim.g.bare ~= nil

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

vim.cmd [[packadd! cfilter]]
vim.cmd [[packadd! matchit]]
