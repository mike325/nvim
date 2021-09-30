local nvim = require 'neovim'

local cmd = {
    'gcc',
}

vim.list_extend(cmd, RELOAD('filetypes.cpp').default_flags.gcc)
table.insert(cmd, '%')

nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))
