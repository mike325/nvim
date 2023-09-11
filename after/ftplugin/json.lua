-- " Json is used as config files, this enables comments for them
vim.opt_local.commentstring = '// %s'
if vim.fn.executable 'jq' == 1 then
    vim.opt_local.formatprg = 'jq .'
end
