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

vim.g.minimal = true
vim.g.bare = true

if vim.env.TMUX_WINDOW then
    local socket = vim.fn.stdpath 'cache' .. '/socket.win' .. vim.env.TMUX_WINDOW
    if vim.fn.filereadable(socket) ~= 1 then
        vim.fn.serverstart(socket)
    end
end

require 'utils.ft_detect'

require 'completions'
require 'globals'
require 'watch_files'

require('threads.parse').ssh_hosts()

if vim.g.minimal and not vim.g.bare then
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

require 'configs.autocmds'
vim.api.nvim_create_autocmd({ 'VimEnter' }, {
    desc = 'Setup neovim in Man mode',
    group = vim.api.nvim_create_augroup('SetupMan', {}),
    pattern = '*',
    once = true,
    callback = function(_)
        require 'configs.options'
        require 'configs.mappings'
        require 'configs.commands'

        -- NOTE: overload/replace vim.* functions
        require 'overloads.notify'
        require 'overloads.ui.open'
        require 'overloads.ui.select'
        -- require 'overloads.ui.input'
        -- require 'overloads.paste'
    end,
})

vim.api.nvim_create_autocmd({ 'FileType' }, {
    desc = 'Force man setup specific filetype options',
    group = vim.api.nvim_create_augroup('ForceMapConfigs', {}),
    pattern = 'man',
    callback = function(_)
        vim.cmd.luafile(vim.api.nvim_get_runtime_file('after/ftplugin/man.lua', false))
    end,
})
