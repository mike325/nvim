if vim.loader then
    vim.loader.enable()
end

if not vim.keycode then
    vim.keycode = function(str)
        return vim.api.nvim_replace_termcodes(str, true, true, true)
    end
end

if vim.version.lt(vim.version(), { 0, 9 }) then
    vim.api.nvim_err_writeln 'Neovim version is too old!! please use update it'
end

if not vim.base64 then
    vim.base64 = {
        encode = require('utils.strings').base64_encode,
        decode = require('utils.strings').base64_decode,
    }
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

if vim.fn.has 'win32' == 1 then
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
elseif vim.fs.basename(vim.go.shell) == 'tcsh' or vim.fs.basename(vim.go.shell) == 'csh' then
    local function executable(shell)
        return vim.fn.executable(shell) == 1
    end
    local shell = vim.iter({ 'zsh', 'bash' }):filter(executable):map(vim.fn.exepath):peek()
    if shell then
        vim.go.shell = shell
    end
end

vim.go.termguicolors = true
vim.g.mapleader = ' '

vim.g.minimal = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
vim.g.bare = vim.env.VIM_BARE ~= nil or vim.g.bare ~= nil or not vim.g.has_ui

require 'globals'

-- NOTE: overload/replace vim.* functions
require 'overloads.notify'
require 'overloads.ui.open'

if vim.g.has_ui then
    -- TODO: Add support for gum to ask for input/select items in CLI mode
    require 'overloads.ui.select'
    -- require 'overloads.ui.input'
    -- require 'overloads.paste'

    require 'completions'
    require 'watch_files'
    require('threads.parse').ssh_hosts()

    if vim.env.TMUX_WINDOW then
        local socket = vim.fn.stdpath 'cache' .. '/socket.win' .. vim.env.TMUX_WINDOW
        if vim.fn.filereadable(socket) ~= 1 then
            vim.fn.serverstart(socket)
        end
    end

    require('nvim').setup(false)
    vim.cmd.packadd { args = { 'matchit' }, bang = false }
else
    -- TODO: This is a setup for script run using -l flag
    -- Missing things,
    -- - stdio handle, specially stdin; stdout/stderr works using vim.notify custom backend
    -- - generic arg parsing
    -- - logging to file
    local hosts = require('threads.parsers').sshconfig()
    for host, attrs in pairs(hosts) do
        STORAGE.hosts[host] = attrs
    end
end
