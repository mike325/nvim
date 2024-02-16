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

        if not vim.list_contains then
            vim.list_contains = vim.tbl_contains
        end

        if not vim.base64 then
            vim.base64 = {
                encode = require('utils.strings').base64_encode,
                decode = require('utils.strings').base64_decode,
            }
        end

        -- NOTE: this only spawns async jobs, which should be detach, sync jobs
        --       does not work because `vim.wait` is not available on threads
        if not vim.system then
            local ok, system = pcall(require, 'vim._system')
            if ok then
                vim.system = function(cmd, opts, on_exit)
                    if type(opts) == 'function' then
                        on_exit = opts
                        opts = nil
                    end
                    return system.run(cmd, opts, on_exit)
                end
            end
        end
    end

    local args = thread_args
    if thread_args then
        if type(thread_args) == type '' and thread_args ~= '' then
            args = vim.json.decode(thread_args)

            args.args = args.args or {}
            args.context = args.context or { (vim.loop.cwd():gsub('\\', '/')) }
            args.functions = args.functions or {}

            if next(args.functions) ~= nil then
                for k, v in pairs(args.functions) do
                    args.functions[k] = loadstring(v)
                end
            end
        elseif type(thread_args) == type {} then
            args.args = args.args or {}
            args.context = args.context or { (vim.loop.cwd():gsub('\\', '/')) }
            args.functions = args.functions or {}
        end
    else
        args = {
            args = {},
            context = { (vim.loop.cwd():gsub('\\', '/')) },
            functions = {},
        }
    end

    return args
end

function M.add_thread_context(opts)
    vim.validate {
        opts = { opts, { 'string', 'table', 'number', 'bool' }, true },
    }

    opts = opts or {}

    local thread_opts = {
        functions = {},
        args = {},
        context = {},
    }

    -- NOTE: we should group opts into categories
    -- - Thread real args should go into "args" key
    -- - Dumped functions should go into "functions" key
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
    context.cwd = context.cwd or (vim.loop.cwd():gsub('\\', '/'))

    thread_opts.context = context
    thread_opts.version = vim.version()

    return thread_opts
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
                local ok, data = pcall(vim.json.decode, o)
                if ok then
                    cb(data)
                else
                    vim.notify(
                        'Failed to decode return value from thread\nnot valid json data: ' .. o .. '\n' .. data,
                        vim.log.levels.ERROR,
                        { title = 'Thread' }
                    )
                end
            else
                vim.notify(
                    'Something when wrong, got an empty string from another thread',
                    vim.log.levels.ERROR,
                    { title = 'Thread' }
                )
            end
        end)
    )

    work:queue(vim.json.encode(M.add_thread_context(opts)))
end

return M
