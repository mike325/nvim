vim.opt_local.number = true
vim.opt_local.relativenumber = true
vim.opt_local.buflisted = true
vim.opt_local.list = false

vim.cmd [[nnoremap <silent> <nowait> <buffer> q <cmd>q!<CR>]]
vim.cmd [[nnoremap <silent> <nowait> <buffer> <CR> <C-]>]]
