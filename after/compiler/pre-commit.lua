local nvim = require 'neovim'

local cmd = {
    'pre-commit',
}
nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))
nvim.ex.CompilerSet('errorformat=' .. table.concat(RELOAD('mappings').precommit_efm, ','):gsub(' ', '\\ '))

vim.b.current_compiler = 'pre-commit'
