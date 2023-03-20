local M = {}

function M.find(thread_args)
    local encode = type(thread_args) == type ''
    thread_args = require('threads').init(thread_args)

    local args = thread_args.args
    local functions = thread_args.functions

    local target
    if functions.filter then
        target = functions.filter
    else
        target = args.target
        if type(target) == 'string' and target:match '[%[%]*+?^$]' then
            local filter_pattern = target
            local function filter(filename, _)
                return filename:match(filter_pattern) ~= nil
            end
            target = filter
        elseif type(target) == 'table' then
            for _, p in ipairs(target) do
                if p:match '[%[%]*+?^$]' then
                    local filter_pattern = target
                    local function filter(filename, _)
                        for _, f in ipairs(filter_pattern) do
                            if filename:match(f) ~= nil then
                                return true
                            end
                        end
                        return false
                    end
                    target = filter
                    break
                end
            end
        end
    end

    local opts = args.opts or { type = 'file' }
    if not opts.limit then
        opts.limit = math.huge
    end
    local results = vim.fs.find(target, opts)
    thread_args.results = results
    thread_args.functions = nil
    thread_args.args = nil
    return (vim.is_thread() and encode) and vim.json.encode(results) or results
end

function M.async_find(opts)
    vim.validate {
        opts = { opts, 'table' },
        cb = { opts.cb, 'function' },
        target = { opts.target, { 'string', 'table' }, true },
        filter = { opts.filter, 'function', true },
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

    require('threads').queue_thread(M.find, cb, find_opts)
end

return M
