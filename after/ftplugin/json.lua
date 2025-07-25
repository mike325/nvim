-- " Json is used as config files, this enables comments for them
vim.bo.commentstring = '// %s'
if vim.fn.executable 'jq' == 1 then
    vim.bo.formatprg = 'jq .'
end

vim.bo.formatexpr = ''
