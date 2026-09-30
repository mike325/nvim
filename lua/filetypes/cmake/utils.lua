local M = {}

function M.execute(args)
    vim.validate {
        arg = { arg, 'table', true },
    }
    args = args or {}

    for idx, arg in ipairs(args) do
        args[idx] = vim.fn.expand(arg)
    end

    local cmd = { 'cmake' }
    vim.list_extend(cmd, args)
    require('async').report(cmd, { open = true, jump = true })
end

function M.build(cmake)
    vim.validate {
        cmake = { cmake, 'table' },
    }

    local cmd = { 'cmake', '--build', '.', '--config', cmake.build_type }
    vim.list_extend(cmd, cmake.args)
    require('async').report(cmd, { open = true, jump = true })
end

return M
