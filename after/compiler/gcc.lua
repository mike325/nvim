local nvim = require 'neovim'

local cmd = {
    'gcc',
}

vim.list_extend(cmd, RELOAD('filetypes.cpp').makeprg.gcc)
table.insert(cmd, '%')

nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))

vim.b.current_compiler = 'gcc'
