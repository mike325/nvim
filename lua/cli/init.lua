-- TODO: This is a setup for script run using -l flag

-- Missing things,
-- - stdio handle, specially stdin; stdout/stderr works using vim.notify custom backend
-- - arg parsing
-- - logging

if vim.loader then
    vim.loader.enable()
end

local nvim = require 'nvim'

if not nvim.has { 0, 9 } then
    error 'Neovim version is too old!! please use update it'
    os.exit(1)
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
require 'globals'

vim.g.minimal = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
vim.g.bare = vim.env.VIM_BARE ~= nil or vim.g.bare ~= nil
-- NOTE: overload/replace vim.* functions
require 'overloads.notify'
require 'overloads.ui.open'
-- TODO: Add support for gum to ask for input/select items in CLI mode
-- require 'overloads.ui.select'
-- require 'overloads.ui.input'
-- require 'overloads.paste'

local hosts = require('threads.parsers').sshconfig()
for host, attrs in pairs(hosts) do
    STORAGE.hosts[host] = attrs
end
