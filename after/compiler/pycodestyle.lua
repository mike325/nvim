local nvim = require 'neovim'
local pyignores = RELOAD('filetypes.python').pyignores

local cmd = { 'pycodestyle' }
vim.list_extend(cmd, { '--max-line-length=120', '--ignore=' .. table.concat(pyignores, ',') })
table.insert(cmd, '%')

nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))

vim.b.current_compiler = 'pycodestyle'
