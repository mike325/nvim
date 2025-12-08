if vim.fn.executable 'xmllint' == 1 then
    vim.bo.formatprg = 'xmllint --format -'
end

vim.bo.formatexpr = ''
vim.bo.tabstop = 2
vim.bo.shiftwidth = 0
vim.bo.softtabstop = -1
