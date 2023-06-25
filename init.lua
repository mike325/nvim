-- luacheck: max line length 170
if vim.loader then
    vim.loader.enable()
end

local nvim = require 'nvim'

if not nvim.has { 0, 9 } then
    vim.api.nvim_err_writeln 'Neovim version is too old!! please use update it'
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
vim.g.loaded_python_provider = 0
vim.g.loaded_python3_provider = 0

vim.g.show_diagnostics = true
vim.g.alternates = {}
vim.g.tests = {}
vim.g.makefiles = {}
vim.g.parsed = {}
vim.g.short_branch_name = true

vim.g.port = 0x8AC

-- vim.g.minimal = false
-- vim.g.bare = false

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

vim.opt.termguicolors = true
vim.g.mapleader = ' '

require 'utils.ft_detect'
require 'completions'
require 'globals'

local is_min = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
local is_bare = vim.env.VIM_BARE ~= nil or vim.g.bare ~= nil

require('threads.parse').ssh_hosts()
local ssh_config = vim.loop.os_homedir():gsub('\\', '/') .. '/.ssh/config'
if require('utils.files').is_file(ssh_config) then
    local ssh_watcher
    ssh_watcher = require('watcher.file'):new(ssh_config, function(err, fname, status)
        if not err or err == '' then
            require('threads.parse').ssh_hosts()
        else
            vim.notify(
                'Something went on file watcher for ' .. fname .. '\n' .. err,
                'ERROR',
                { title = 'Watcher ' .. status }
            )
            ssh_watcher:stop()
        end
    end)
    ssh_watcher:start()
end

if vim.env.TMUX_WINDOW then
    local socket = vim.fn.stdpath 'cache' .. '/socket.win' .. vim.env.TMUX_WINDOW
    if vim.fn.filereadable(socket) ~= 1 then
        vim.fn.serverstart(socket)
    end
end

require 'configs.options'
require 'configs.mappings'
require 'configs.autocmds'

vim.cmd.packadd { args = { 'cfilter' }, bang = false }
vim.cmd.packadd { args = { 'matchit' }, bang = false }
vim.cmd.packadd { args = { 'termdebug' }, bang = false }

if nvim.executable 'git' and not is_bare then
    local is_setup = require 'setup'()
    if is_setup then
        require('lazy').setup('plugins', {})
    end
elseif not is_min and not is_bare then
    vim.notify('Missing git! cannot install plugins', 'WARN', { title = 'Nvim Setup' })
end

require 'messages'
