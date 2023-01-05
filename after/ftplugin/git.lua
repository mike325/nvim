vim.opt_local.foldenable = true
vim.opt_local.foldmethod = 'syntax'

vim.opt_local.swapfile = false
vim.opt_local.undofile = false

vim.keymap.set('n', 'q', '<cmd>q!<CR>', { noremap = true, silent = true, nowait = true, buffer = true })
vim.keymap.set('n', '=', 'za', { noremap = true, silent = true, nowait = true, buffer = true })
