local nvim = require 'neovim'

local cmd = {
    'clang',
}

vim.list_extend(cmd, RELOAD('filetypes.cpp').makeprg.clang)
table.insert(cmd, '%')

nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))

vim.b.current_compiler = 'clang'
