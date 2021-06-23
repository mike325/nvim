local executable = require'utils.files'.executable

-- vim.opt_local.foldmethod = 'syntax'
vim.opt_local.expandtab = true
-- vim.opt_local.shiftround = true
vim.opt_local.tabstop = 4
vim.opt_local.shiftwidth = 0
vim.opt_local.softtabstop = -1
vim.opt_local.commentstring = '// %s'
vim.opt_local.define = [[^\(#\s*define\|[a-z]*\s*const\(expr\)\?\s*[a-z]*\)]]

if executable('clang-format') then
    vim.opt_local.formatprg = 'clang-format --style=file --fallback-style=WebKit'
end

require'filetypes.cpp'.setup()
