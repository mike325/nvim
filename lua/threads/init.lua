local M = {}

function M.init(thread_args)
    if vim.is_thread() then
        require 'globals'
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
    end

    if type(thread_args) == type '' and thread_args ~= '' then
        thread_args = vim.json.decode(thread_args)

        thread_args.args = thread_args.args or {}
        thread_args.context = thread_args.context or {}
        thread_args.functions = thread_args.functions or {}

        if #thread_args.functions > 0 then
            for k, v in pairs(thread_args.functions) do
                thread_args.fucntions[k] = loadstring(v)
            end
        end
    end

    return thread_args
end

function M.queue_thread(thread, cb, opts)
    vim.validate {
        thread = { thread, 'function' },
        cb = { cb, 'function' },
        opts = { opts, { 'string', 'table', 'number', 'bool' }, true },
    }

    -- TODO: There should be a way to init the threads common state using M.init() and pcall the `thread` function
    -- Common init state
    -- - global functions
    -- - vim.env
    -- - vim.fs
    -- - copy of all global, buffer and tab variables vim ?
    -- - pcall thread function and collect errors
    -- - Parse thread opts/function/args before calling the thread function
    local work = vim.loop.new_work(
        thread,
        vim.schedule_wrap(function(o)
            if type(o) == type '' and o ~= '' then
                cb(vim.json.decode(o))
            else
                vim.notify(
                    'Something when wrong, got an empty string from another thread',
                    'ERROR',
                    { title = 'Thread' }
                )
            end
        end)
    )

    local thread_opts = {
        functions = {},
        args = {},
        context = {},
    }

    -- NOTE: we should group opts into categories
    -- - Thread real args should go into "args" key
    -- - Dumped fucntions should go into "functions" key
    -- - Common context opts should go into a "context" key
    if opts then
        if type(opts) == type {} and not vim.tbl_islist(opts) then
            for k, v in pairs(opts) do
                if type(v) == 'function' then
                    thread_opts.functions[k] = string.dump(v)
                else
                    thread_opts.args[k] = v
                end
            end
        elseif type(opts) == 'function' then
            thread_opts.functions.helper = string.dump(opts)
        else
            thread_opts.args = opts
        end
    end

    local context = {}

    context.buf = context.buf or vim.api.nvim_get_current_buf()
    context.bufname = context.bufname or vim.api.nvim_buf_get_name(context.buf)
    local prefix = context.bufname:match '^(%w+)://'
    if prefix then
        context.bufname = context.bufname:gsub('^%w+://', '')
        if prefix == 'fugitive' then
            context.bufname = context.bufname:gsub('%.git//?[%w%d]+//?', '')
        end
    end
    context.dirname = vim.fs.dirname(context.bufname)
    context.buf_is_virtual = prefix ~= nil or vim.opt_local.buftype:get() ~= '' or context.bufname == ''
    context.cwd = context.cwd or vim.loop.cwd():gsub('\\', '/')

    thread_opts.context = context

    work:queue(vim.json.encode(thread_opts))
end

return M
