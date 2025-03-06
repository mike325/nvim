local M = {}

function M.find(thread_args, async)
    local encode = type(thread_args) == type ''
    thread_args = require('threads').init(thread_args)

    local args = thread_args.args
    local functions = thread_args.functions

    local target
    if functions.filter then
        target = function(name, path)
            return functions.filter(name, path, thread_args)
        end
    else
        -- TODO: Add support to match paths
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

    local blacklist = {
        ['.git'] = true,
        ['.svn'] = true,
        ['.cache'] = true,
        ['__pycache__'] = true,
        ['.vscode'] = true,
        ['.vscode_clangd_setup'] = true,
        ['node_modules'] = true,
    }

    local opts = args.opts or { type = 'file' }
    if not opts.limit then
        opts.limit = math.huge
    end

    local candidates = {}
    local path = '.'
    opts.path = opts.path or path
    for fname, ftype in vim.fs.dir(path) do
        if ftype == 'file' then
            if
                (type(target) == type '' and target == fname)
                or (type(target) == type {} and vim.list_contains(target, fname))
                or (type(target) == 'function' and target(fname))
            then
                table.insert(candidates, vim.fs.joinpath(path, fname))
            end
        elseif not blacklist[fname] then
            local results = vim.fs.find(target, opts)
            if #results > 0 then
                candidates = vim.list_extend(candidates, results)
            end
        end
    end

    thread_args.results = candidates
    thread_args.functions = nil
    thread_args.args = nil
    local rt = (vim.is_thread() and encode) and vim.json.encode(candidates) or candidates
    if async then
        vim.uv.async_send(async, rt)
        return
    end
    return rt
end

function M.async_find(opts)
    vim.validate('opts', opts, 'table')
    vim.validate('cb', opts.cb, 'function')
    vim.validate('target', opts.target, { 'string', 'table' }, true)
    vim.validate('filter', opts.filter, 'function', true)
    vim.validate('path', opts.path, 'string', true)

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
