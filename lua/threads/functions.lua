local M = {}

function M.find_mathches(opts)
    if not vim.env then
        vim.env = setmetatable({}, {
            __index = function(_, k)
                local v = vim.loop.os_getenv(k)
                if v == nil then
                    return nil
                end
                return v
            end,
            __newindex = function(_, k, v)
                vim.loop.os_setenv(k, v)
            end,
        })
    end

    if not vim.fs then
        vim.fs = require 'vim.fs'
    end

    opts = vim.json.decode(opts)

    local target = opts.target:gsub('%.', '%%.'):gsub('%-', '%%-')
    local filter
    if opts.filter then
        filter = loadstring(opts.filter)
    else
        filter = function(filename)
            return filename:match(target) ~= nil
        end
    end

    local results = vim.fs.find(filter, { type = 'file', limit = math.huge })
    opts.results = results

    return vim.is_thread() and vim.json.encode(opts) or opts
end

function M.find(opts)
    vim.validate {
        opts = { opts, 'table' },
        cb = { opts.cb, 'function' },
        target = { opts.target, 'string' },
        path = { opts.path, 'string', true },
    }
    opts.path = opts.path or vim.loop.cwd()
    local cb = opts.cb
    opts.cb = nil
    if opts.filter then
        opts.filter = string.dump(opts.filter)
    end
    local work = vim.loop.new_work(M.find_mathches, vim.schedule_wrap(cb))
    work:queue(vim.json.encode(opts))
end

return M
