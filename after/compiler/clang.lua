local nvim = require'neovim'

local cmd = {
    'clang'
}

vim.list_extend(cmd, RELOAD'filetypes.cpp'.default_flags.clang)
table.insert(cmd, '%')

nvim.ex.CompilerSet('makeprg='..table.concat(cmd, '\\ '))
