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

require'setup'()
require'globals'

vim.g.mapleader = ' '

pcall(require, 'plugins.setup')

vim.cmd[[packadd! cfilter]]
vim.cmd[[packadd! matchit]]
