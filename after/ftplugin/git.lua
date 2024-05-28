vim.wo.foldenable = true
vim.wo.foldmethod = 'syntax'

vim.bo.swapfile = false
vim.bo.undofile = false

vim.keymap.set('n', 'q', '<cmd>q!<CR>', { noremap = true, silent = true, nowait = true, buffer = true })
vim.keymap.set('n', '=', 'za', { noremap = true, silent = true, nowait = true, buffer = true })
