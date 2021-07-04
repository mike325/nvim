-- local function executable(exe)
--     return vim.fn.executable(exe) == 1
-- end

-- local bare = vim.env.VIM_BARE ~= nil
-- local min = vim.env.VIM_MIN ~= nil

-- if not executable('git') then
--     bare = true
-- end

vim.g.loaded_2html_plugin      = 1
vim.g.loaded_gzip              = 1
vim.g.loaded_rrhelper          = 1
vim.g.loaded_tarPlugin         = 1
vim.g.loaded_zipPlugin         = 1
vim.g.loaded_tutor_mode_plugin = 1
vim.g.loaded_tarPlugin         = 1
vim.g.loaded_vimballPlugin     = 1

if vim.fn.has('win32') == 1 then
    -- vim.opt.shell = 'cmd.exe'
    vim.opt.shell = vim.fn.has('win32') == 1 and 'powershell' or 'pwsh'
    vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command [Console]::InputEncoding=[Console]::OutputEncoding=[System.Text.Encoding]::UTF8;'
    vim.opt.shellredir = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    vim.opt.shellpipe = '2>&1 | Out-File -Encoding UTF8 %s; exit $LastExitCode'
    vim.opt.shellquote = ''
    vim.opt.shellxquote = ''
end

require'setup'()
require'globals'

vim.g.mapleader = ' '

pcall(require, 'plugins.setup')

vim.cmd[[packadd! cfilter]]
vim.cmd[[packadd! matchit]]
