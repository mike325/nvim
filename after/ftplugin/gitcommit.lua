vim.bo.bufhidden = 'delete'
vim.bo.readonly = false
vim.bo.expandtab = true
vim.bo.modifiable = true
vim.bo.swapfile = false
vim.bo.textwidth = 80

vim.bo.complete = table.concat(vim.list_extend(vim.split(vim.bo.complete, ','), { 'k', 'kspell' }), ',')

vim.wo.spell = true
