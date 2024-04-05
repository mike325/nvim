if vim.fn.executable 'xmllint' == 1 then
    vim.opt_local.formatprg = 'xmllint --format -'
end
