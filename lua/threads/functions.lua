local M = {}

function M.find_mathches(thread_args)
    local encode = type(thread_args) == type ''
    thread_args = require('threads').init(thread_args)

    local args = thread_args.args
    local functions = thread_args.functions

    local filter
    if functions.filter then
        filter = functions.filter
    else
        local target = args.target:gsub('%.', '%%.'):gsub('%-', '%%-')
        filter = function(filename)
            return filename:match(target) ~= nil
        end
    end

    local opts = args.opts or { type = 'file', limit = math.huge }

    local results = vim.fs.find(filter, opts)
    thread_args.results = results
    thread_args.functions = nil
    return (vim.is_thread() and encode) and vim.json.encode(thread_args) or thread_args
end

function M.find(opts)
    vim.validate {
        opts = { opts, 'table' },
        cb = { opts.cb, 'function' },
        target = { opts.target, 'string', true },
        filter = { opts.filter, { 'string', 'function' }, true },
        path = { opts.path, 'string', true },
    }
    assert(opts.filter or opts.target, debug.traceback 'Missing both filter and target opts')

    local find_opts = {
        filter = opts.filter,
        target = opts.target,
        opts = {
            path = opts.path,
            upward = opts.upward,
            stop = opts.stop,
            type = opts.type,
            limit = opts.limit,
        },
    }

    local cb = opts.cb
    opts.cb = nil
    opts.filter = nil
    opts.target = nil
    opts.path = nil
    opts.upward = nil
    opts.stop = nil
    opts.type = nil
    opts.limit = nil
    if not next(find_opts.opts) then
        find_opts.opts = nil
    end

    for k, v in pairs(opts) do
        find_opts[k] = v
    end

    require('threads').queue_thread(M.find_mathches, cb, find_opts)
end

return M
