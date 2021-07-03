local executable = require'utils.files'.executable

vim.opt_local.expandtab = true
-- vim.opt_local.shiftround = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 0
vim.opt_local.softtabstop = -1

vim.opt_local.includeexpr = [[substitute(v:fname,'\.','/','g')]]
vim.opt_local.define = [[\s*\(local\s\+\)\?\(function\s\+\(\i\+[.:]\)\?\|\ze\i\+\s*=\s*\|\(\i\+[.:]\)\?\ze\s*=\s*\)]]

vim.opt_local.suffixesadd:prepend('.lua')
vim.opt_local.suffixesadd:prepend('init.lua')
vim.opt_local.path:prepend(require'sys'.base..'/lua')

if executable('luacheck') then
    vim.opt_local.makeprg = 'luacheck --max-cyclomatic-complexity 15 --std luajit --formatter plain %'
    vim.opt_local.errorformat = '%f:%l:%c: %m'
end
