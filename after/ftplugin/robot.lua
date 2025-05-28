vim.bo.comments = ':#'
vim.bo.commentstring = '# %s'

local cwd = vim.pesc(vim.uv.cwd() .. '/')
local basedir = vim.fs.dirname(vim.fs.dirname(vim.api.nvim_buf_get_name(0)))

basedir = (basedir:gsub(cwd, ''))
basedir = basedir:gsub(vim.fs.basename(basedir) .. '$', 'resources')
vim.opt_local.path:append(basedir)

vim.wo.spell = false
