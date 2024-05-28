vim.wo.number = false
vim.wo.relativenumber = true
vim.wo.list = false
vim.wo.wrap = false
vim.bo.buflisted = true
-- vim.bo.bufhidden = 'wipe'

vim.keymap.set('n', 'q', '<cmd>q!<CR>', { noremap = true, silent = true, nowait = true, buffer = true })
vim.keymap.set('n', '<CR>', '<C-]>', { noremap = true, silent = true, nowait = true, buffer = true })
