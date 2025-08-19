local iswin = require('sys').name == 'windows'

vim.bo.comments = ':#'
vim.bo.commentstring = '# %s'

vim.opt_local.suffixesadd:prepend '.robot'
vim.opt_local.suffixesadd:prepend '.py'

local paths = vim.split(vim.env.PYTHONPATH, iswin and ';' or ':')
vim.opt_local.path:append(paths)

vim.wo.spell = false
