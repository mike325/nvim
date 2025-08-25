-- " Json is used as config files, this enables comments for them
vim.bo.commentstring = '// %s'
if vim.fn.executable 'jq' == 1 then
    vim.bo.formatprg = 'jq .'
end

vim.bo.formatexpr = ''
vim.bo.tabstop = 2
vim.bo.shiftwidth = 0
vim.bo.softtabstop = -1
