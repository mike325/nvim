local M = {}

function M.execute(args)
    vim.validate {
        arg = { arg, 'table', true },
    }
    args = args or {}

    for idx, arg in ipairs(args) do
        args[idx] = vim.fn.expand(arg)
    end

    local cmd = { 'make' }
    vim.list_extend(cmd, args)
    require('async').report(cmd, { open = true, jump = true })
end

function M.copy_template()
    local template = string.format('%s/skeletons/Makefile', vim.fn.stdpath('config'):gsub('\\', '/'))
    local utils = require 'utils.files'
    if not utils.is_file 'Makefile' then
        utils.copy(template, '.')
    end
end

return M
