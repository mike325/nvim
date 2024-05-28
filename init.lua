if vim.loader then
    vim.loader.enable()
end

if not vim.list_contains then
    vim.list_contains = vim.tbl_contains
end

if not vim.isarray then
    vim.isarray = vim.tbl_islist
end

if not vim.islist then
    vim.islist = vim.tbl_islist
end

local nvim = require 'nvim'

if not nvim.has { 0, 9 } then
    vim.api.nvim_err_writeln 'Neovim version is too old!! please use update it'
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
vim.g.short_branch_name = true

vim.g.port = 0x8AC

if nvim.has 'win32' then
    -- vim.go.shell = 'cmd.exe'
    vim.go.shell = 'powershell'
    vim.go.shellcmdflag = table.concat({
        '-NoLogo',
        '-NoProfile',
        '-ExecutionPolicy',
        'RemoteSigned',
        '-Command',
        -- '[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;',
    }, ' ')
    vim.go.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    vim.go.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    vim.go.shellquote = ''
    vim.go.shellxquote = ''

    vim.go.shellslash = true
end

vim.go.termguicolors = true
vim.g.mapleader = ' '

vim.g.minimal = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
vim.g.bare = vim.env.VIM_BARE ~= nil or vim.g.bare ~= nil

if vim.env.TMUX_WINDOW then
    local socket = vim.fn.stdpath 'cache' .. '/socket.win' .. vim.env.TMUX_WINDOW
    if vim.fn.filereadable(socket) ~= 1 then
        vim.fn.serverstart(socket)
    end
end

require 'utils.filetype_detect'

require 'globals'
require 'completions'
require 'watch_files'

require 'configs.options'
require 'configs.mappings'
require 'configs.commands'
require 'configs.autocmds'

require('threads.parse').ssh_hosts()

if not vim.g.bare and not vim.g.minimal then
    nvim.setup.lazy(false)
elseif vim.g.minimal and not vim.g.bare then
    local lazy_root = vim.fs.dirname(nvim.setup.get_lazypath())
    local mini_lazy = string.format('%s/mini.nvim', lazy_root)

    local ok, _
    if vim.loop.fs_stat(mini_lazy) then
        vim.opt.rtp:prepend(mini_lazy)
        ok = true
    else
        ok, _ = pcall(vim.cmd.packadd, { args = { 'mini.nvim' }, bang = true })
    end

    if ok then
        vim.api.nvim_create_autocmd('VimEnter', {
            desc = 'Setup Mini plugins',
            group = vim.api.nvim_create_augroup('SetupMini', { clear = true }),
            pattern = '*',
            once = true,
            callback = function()
                require 'configs.mini'
                vim.cmd.helptags 'ALL'
            end,
        })
    end
elseif not vim.g.minimal and not vim.g.bare then
    vim.notify('Missing git! cannot install plugins', vim.log.levels.WARN, { title = 'Nvim Setup' })
end

vim.cmd.packadd { args = { 'matchit' }, bang = false }
vim.cmd.packadd { args = { 'termdebug' }, bang = false }

-- NOTE: overload/replace vim.* functions
require 'overloads.notify'
require 'overloads.ui.open'
require 'overloads.ui.select'
-- require 'overloads.ui.input'
-- require 'overloads.paste'
