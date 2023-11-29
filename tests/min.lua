if vim.loader then
    vim.loader.enable()
end

local nvim = require 'nvim'

if not nvim.has { 0, 9 } then
    error 'Neovim version is too old!! please use update it'
end

if not vim.list_contains then
    vim.list_contains = vim.tbl_contains
end

if not vim.base64 then
    vim.base64 = {
        encode = require('utils.strings').base64_encode,
        decode = require('utils.strings').base64_decode,
    }
end

if not vim.keymap then
    vim.keymap = nvim.keymap
end

vim.g.has_ui = #vim.api.nvim_list_uis() > 0

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
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0

vim.g.show_diagnostics = true
vim.g.alternates = {}
vim.g.tests = {}
vim.g.makefiles = {}
vim.g.parsed = {}
vim.g.short_branch_name = true

vim.g.port = 0x8AC

if nvim.has 'win32' then
    -- vim.opt.shell = 'cmd.exe'
    vim.opt.shell = 'powershell'
    vim.opt.shellcmdflag = table.concat({
        '-NoLogo',
        '-NoProfile',
        '-ExecutionPolicy',
        'RemoteSigned',
        '-Command',
        -- '[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;',
    }, ' ')
    vim.opt.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    vim.opt.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    vim.opt.shellquote = ''
    vim.opt.shellxquote = ''

    vim.opt.shellslash = true
end

vim.opt.termguicolors = true
vim.g.mapleader = ' '

require 'utils.ft_detect'

require 'globals'

vim.g.minimal = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
vim.g.bare = vim.env.VIM_BARE ~= nil or vim.g.bare ~= nil
-- NOTE: overload/replace vim.* functions
require 'overloads.notify'
require 'overloads.ui.open'
require 'overloads.ui.select'
-- require 'overloads.ui.input'
-- require 'overloads.paste'

local data_dir = vim.fn.stdpath('data'):gsub('\\', '/')

local mini_possible_paths = {
   data_dir .. '/site/pack/host/start/',
   data_dir .. '/site/pack/host/opt/',
   data_dir .. '/site/pack/packer/start/',
   data_dir .. '/site/pack/packer/opt/',
}

for _, mini_path in ipairs(mini_possible_paths) do
    vim.opt.rtp:append(mini_path .. 'mini.nvim/')
end

vim.cmd.packadd { args = { 'mini.nvim' }, bang = false }
require 'configs.mini'
