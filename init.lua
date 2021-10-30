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

if vim.fn.has 'win32' == 1 then
    vim.opt.shell = 'cmd.exe'
    -- local powershell_args = {
    --     '-NoLogo',
    --     '-NoProfile',
    --     '-ExecutionPolicy',
    --     'RemoteSigned',
    --     '-Command',
    --     '[Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;',
    -- }
    -- vim.opt.shell = vim.fn.has('win32') == 1 and 'powershell' or 'pwsh'
    -- vim.opt.shellcmdflag = table.concat(powershell_args, ' ')
    -- vim.opt.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    -- vim.opt.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    -- vim.opt.shellquote = ''
    -- vim.opt.shellxquote = ''
end

vim.g.mapleader = ' '
vim.cmd [[packadd! cfilter]]
vim.cmd [[packadd! matchit]]

require 'messages'
require 'globals'
RELOAD('filetypes.python').pynvim_setup()

if vim.fn.executable 'git' == 1 then
    if vim.fn.filereadable './plugin/packer_compiled.lua' ~= 1 then
        require 'setup'()
        pcall(require, 'plugins')
    end
elseif vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil or vim.env.VIM_BARE ~= nil or vim.g.bare ~= nil then
    vim.notify('Missing git! cannot install plugins', 'WARN', { title = 'Nvim Setup' })
end

-- require'storage'
require('utils.functions').get_ssh_hosts()
