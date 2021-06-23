vim.opt_local.bufhidden = 'delete'
vim.opt_local.readonly = false

vim.opt_local.expandtab  = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 0
vim.opt_local.softtabstop = -1

vim.opt_local.modifiable = true
vim.opt_local.swapfile = false

vim.opt_local.spell = true

vim.opt_local.complete:append('k')
vim.opt_local.complete:append('kspell')


vim.opt_local.textwidth = 80

-- require"utils.helpers".abolish(vim.opt_local.spelllang)
