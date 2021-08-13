local executable = require'utils.files'.executable

vim.opt_local.expandtab   =  false
vim.opt_local.tabstop     = 4
vim.opt_local.shiftwidth  = 0
vim.opt_local.softtabstop = -1

if executable('make') then
    RELOAD'filetypes.make'.setup()
end
