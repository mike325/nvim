local nvim = require 'neovim'

local cmd = {
    'g++',
}

vim.list_extend(cmd, RELOAD('filetypes.cpp').default_flags['g++'])
table.insert(cmd, '%')

nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))
