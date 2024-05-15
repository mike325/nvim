vim.opt_local.number = true
vim.opt_local.relativenumber = true
vim.opt_local.buflisted = true
vim.opt_local.list = false
-- vim.opt_local.bufhidden = 'wipe'

vim.keymap.set('n', 'q', '<cmd>q!<CR>', { noremap = true, silent = true, nowait = true, buffer = true })
vim.keymap.set('n', '<CR>', '<C-]>', { noremap = true, silent = true, nowait = true, buffer = true })
