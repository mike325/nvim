local nvim = require 'neovim'

local cmd = {
    'g++',
}

vim.list_extend(cmd, RELOAD('filetypes.cpp').makeprg['g++'])
table.insert(cmd, '%')

nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))

vim.b.current_compiler = 'g++'
