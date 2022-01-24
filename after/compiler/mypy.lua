local nvim = require 'neovim'

local cmd = { 'mypy' }
table.insert(cmd, '%')
nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))

-- local formats = vim.deepcopy(vim.opt.errorformat:get())
local formats = {}
vim.list_extend(formats, {
    '%f:%l: %trror: %m',
    '%f:%l: %tarning: %m',
    '%f:%l: %tote: %m',
    '%f: %trror: %m',
    '%f: %tarning: %m',
    '%f: %tote: %m',
    '%f:%l:%c: %t%n %m',
    '%f:%l:%c:%t: %m',
    '%f:%l:%c: %m',
})

nvim.ex.CompilerSet('errorformat=' .. table.concat(formats, ','):gsub(' ', '\\ '))

vim.b.current_compiler = 'mypy'
