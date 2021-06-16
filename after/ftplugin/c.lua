local executable     = require'utils.files'.executable

-- vim.bo.foldmethod = 'syntax'
vim.bo.expandtab = true
-- vim.bo.shiftround = true
vim.bo.tabstop = 4
vim.bo.shiftwidth = 0
vim.bo.softtabstop = -1
vim.bo.commentstring = '// %s'
vim.bo.define = [[^\(#\s*define\|[a-z]*\s*const\(expr\)\?\s*[a-z]*\)]]

if executable('clang-format') then
    vim.bo.formatprg = 'clang-format --style=file --fallback-style=WebKit'
end

require'filetypes.cpp'.setup()
