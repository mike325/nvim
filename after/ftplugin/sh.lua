local executable = require'utils.files'.executable

vim.opt_local.expandtab = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 0
vim.opt_local.softtabstop = -1
vim.opt_local.define = [[^\(\(function\s\+\)\?\ze\i\+()\|\s*\(local\s\+\)\?\ze\k\+=.*\)]]

if executable('shellcheck') then
    vim.opt_local.makeprg = 'shellcheck -f gcc -x -e 1117 %'
end

if executable('shfmt') then
    vim.opt_local.formatexpr = [[luaeval('RELOAD"filetypes.sh".format()')]]
end
