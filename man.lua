if vim.loader then
    vim.loader.enable()
end

if not vim.version.gt(vim.version(), { 0, 9 }) then
    vim.api.nvim_err_writeln 'Neovim version is too old!! please use update it'
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

if vim.fn.has 'win32' == 1 then
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

vim.opt.runtimepath:append(vim.fn.stdpath 'config')

require 'utils.ft_detect'

require 'completions'
require 'globals'

vim.g.minimal = true
vim.g.bare = true

if vim.env.TMUX_WINDOW then
    local socket = vim.fn.stdpath 'cache' .. '/socket.win' .. vim.env.TMUX_WINDOW
    if vim.fn.filereadable(socket) ~= 1 then
        vim.fn.serverstart(socket)
    end
end

if vim.fn.executable 'git' == 1 then
    vim.opt.packpath:append(string.format('%s/site/', vim.fn.stdpath 'data'))
    local ok, _ = pcall(vim.cmd.packadd, { args = { 'mini.nvim' }, bang = false })
    if ok then
        vim.api.nvim_create_autocmd({ 'VimEnter' }, {
            pattern = '*',
            once = true,
            group = vim.api.nvim_create_augroup('SetupMini', {}),
            callback = function(_)
                require 'configs.mini'
                vim.cmd.helptags 'ALL'
            end,
        })
    end
elseif not vim.g.minimal and not vim.g.bare then
    vim.notify('Missing git! cannot install plugins', vim.log.levels.WARN, { title = 'Nvim Setup' })
end

require 'configs.autocmds'
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    pattern = '*',
    once = true,
    group = vim.api.nvim_create_augroup('SetupMan', {}),
    callback = function(_)
        require 'configs.options'
        require 'configs.mappings'

        -- NOTE: overload/replace vim.* functions
        require 'overloads.notify'
        require 'overloads.ui.open'
        require 'overloads.ui.select'
        -- require 'overloads.ui.input'
        -- require 'overloads.paste'
    end,
})

vim.api.nvim_create_autocmd({ 'filetype' }, {
    pattern = 'man',
    group = vim.api.nvim_create_augroup('ForceMapConfigs', {}),
    callback = function(_)
        vim.cmd.luafile(vim.api.nvim_get_runtime_file('after/ftplugin/man.lua', false))
    end,
})
