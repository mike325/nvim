local M = {}

function M.execute(args)
    vim.validate {
        arg = { arg, 'table', true },
    }
    args = args or {}

    for idx, arg in ipairs(args) do
        args[idx] = vim.fn.expand(arg)
    end

    RELOAD('utils.functions').async_execute {
        cmd = 'make',
        args = args,
        progress = true,
        auto_close = true,
        silent = false,
        title = 'Make',
        callbacks_on_success = function()
            local ns = vim.api.nvim_create_namespace 'makefile'
            vim.diagnostic.reset(ns)
        end,
        callbacks_on_failure = function()
            RELOAD('utils.qf').qf_to_diagnostic 'makefile'
        end,
    }
end

function M.copy_template()
    local template = string.format('%s/skeletons/Makefile', vim.fn.stdpath('config'):gsub('\\', '/'))
    local utils = require 'utils.files'
    if not utils.is_file('Makefile') then
        utils.copy(template, '.')
    end
end

return M
