vim.bo.bufhidden = 'delete'
vim.bo.readonly = false

vim.bo.expandtab  = true
-- vim.bo.shiftround = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 0
vim.bo.softtabstop = -1

vim.bo.modifiable = true
-- vim.bo.backup = false
vim.bo.swapfile = false

vim.wo.spell = true

vim.opt_local.complete:append('k')
vim.opt_local.complete:append('kspell')


vim.bo.textwidth = 80

-- require"utils.helpers".abolish(vim.bo.spelllang)
