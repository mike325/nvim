if vim.fn.executable 'xmllint' == 1 then
    vim.bo.formatprg = 'xmllint --format -'
end

vim.bo.formatexpr = ''
