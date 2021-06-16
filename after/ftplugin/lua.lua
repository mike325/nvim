local executable = require'utils.files'.executable

vim.bo.expandtab = true
-- vim.bo.shiftround = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 0
vim.bo.softtabstop = -1

vim.bo.includeexpr = [[substitute(v:fname,'\\.','/','g')]]
vim.bo.define = [[\s*\(local\s\+\)\?\(function\s\+\(\i\+[.:]\)\?\|\ze\i\+\s*=\s*\|\(\i\+[.:]\)\?\ze\s*=\s*\)]]

vim.opt_local.suffixesadd:prepend('.lua')
vim.opt_local.suffixesadd:prepend('init.lua')
vim.opt_local.path:prepend(require'sys'.base..'/lua')

if executable('luacheck') then
    vim.bo.makeprg = 'luacheck --max-cyclomatic-complexity 15 --std luajit --formatter plain %'
    vim.bo.errorformat = '%f:%l:%c: %m'
end
