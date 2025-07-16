local M = {}

--- @class vim.SystemCompleted
--- @field code integer
--- @field signal integer
--- @field stdout? string
--- @field stderr? string

--- @class vim.SystemObj
--- @field cmd string[]
--- @field pid integer
--- @field wait fun(self: vim.SystemObj, timeout?: integer): vim.SystemCompleted
--- @field kill fun(self: vim.SystemObj, signal: integer|string)
--- @field write fun(self: vim.SystemObj, data?: string|string[])
--- @field is_closing fun(self: vim.SystemObj): boolean

--- @class vim.SystemOpts
--- @field stdin? string|string[]|boolean
--- @field stdout? fun(err:string?, data: string?)|boolean
--- @field stderr? fun(err:string?, data: string?)|boolean
--- @field cwd? string
--- @field env? table<string,string|number>
--- @field clear_env? boolean
--- @field text? boolean
--- @field timeout? integer Timeout in ms
--- @field detach? boolean

---@class Report.Opts
---@field notify (boolean?) notify on completion, default: true
---@field silent (boolean?) Don't notify on fail, default: false
---@field clear (boolean?) Clear quickfix on success, default: true
---@field append (boolean?) Append errors to qf instead of overriding, default: false
---@field uniq (boolean?) Stop previous task before executing, default: true
---@field open (boolean?) Open qf, default: false
---@field jump (boolean?) Jump to the first element, default: false
---@field win (boolean|integer|nil) Use location list instead of quickfix
---@field buf (integer|nil) Buffer to set diagnostics
---@field efm (string|string[]|nil) efm to parse qf results
---@field dump (boolean?) Dump results into the Quickfix/loclist, default: true
---@field progress (boolean?) Show task progress, default: false
---@field opts (vim.SystemOpts?) Override default opts, default: {text = true}
---@field callbacks (fun(out: vim.SystemCompleted)|fun(out: vim.SystemCompleted)[]|nil)
---                 Callback executed after process qf default on_exit

---@class Data
---@field stdout string[]
---@field stderr string[]
---@field output string[]

---Store data and execute callback
---@param err string
---@param data string
---@param hash string
---@param state string[]?
---@param output string[]?
---@param text boolean?
---@param cb fun(err:string?, data: string?)|boolean|nil
local function process_data(err, data, hash, state, output, text, cb)
    if err then
        error(err)
    end

    if text and data then
        data = (data:gsub('\r\n', '\n'))
    end

    if state then
        table.insert(state, data)
    end

    if output then
        table.insert(output, data)
    end

    if vim.is_callable(cb) then
        ---@cast cb fun(err:string?, data: string?)
        cb(err, data)
    end

    local current_task = require('utils.async').get_progress_task() or {}
    if hash == current_task.hash then
        local lines = vim.iter(vim.split(table.concat(state, ''), '\n'))
            :filter(function(l)
                return not l:match '^%s*$'
            end)
            :totable()
        require('utils.windows').push_progress_data(lines)
    end
end

---Process async task exit
---@param out vim.SystemCompleted
---@param state_data Data
---@param cmd string[]
---@param cwd string
---@param opts Report.Opts
local function process_exit(out, state_data, cmd, cwd, opts)
    out.stdout = out.stdout or table.concat(state_data.stdout, '')
    out.stderr = out.stderr or table.concat(state_data.stderr, '')

    require('utils.async').push_output(out, cmd, cwd)
    local hash = require('utils.async').get_hash(cmd, cwd)
    ASYNC.tasks[hash] = nil
    require('utils.async').remove_progress_task(hash)

    local cmd_name = vim.fs.basename(cmd[1])
    local ns_name = string.format('async.%s', cmd_name)
    local qf_utils = RELOAD 'utils.qf'

    if out.code == 0 then
        if opts.notify then
            vim.notify(string.format('cmd: %s succeed', cmd_name), vim.log.levels.INFO, { title = 'Async' })
        end

        if opts.clear then
            local ns = vim.api.nvim_create_namespace(ns_name)
            if not opts.buf then
                vim.diagnostic.reset(ns)
            elseif vim.api.nvim_buf_is_valid(opts.buf) then
                vim.diagnostic.reset(ns, opts.buf)
            end

            local qf = qf_utils.get_list({ context = 1 }, opts.win)
            if qf.context and type(qf.context) == type {} then
                local qf_hash = require('utils.async').get_hash(qf.context.cmd, qf.context.cwd)
                if qf_hash == hash then
                    qf_utils.clear(opts.win)
                end
            end
        end
    elseif out.signal ~= 7 then
        local lines = vim.iter(vim.split(table.concat(state_data.output, ''), '\n'))
            :filter(function(l)
                return not l:match '^%s*$'
            end)
            :totable()

        local qf_opts = {
            items = lines,
            open = opts.open,
            jump = opts.jump,
            efm = opts.efm,
            context = {
                ns_name = ns_name,
                cmd = cmd,
                cwd = cwd,
            },
        }
        if opts.append then
            qf_opts.action = 'a'
        end

        if opts.dump then
            qf_utils.set_list(qf_opts, opts.win)
            qf_utils.qf_to_diagnostic(ns_name, opts.win)
        else
            local items = vim.fn.getqflist({ lines = lines, efm = opts.efm or vim.go.efm }).items
            qf_utils.qf_to_diagnostic(ns_name, opts.win, items)
        end

        if not opts.silent then
            vim.notify(string.format('cmd: %s failed', cmd_name), vim.log.levels.ERROR, { title = 'Async' })
        end
    end

    -- NOTE: Don't process callbacks if the task was killed
    if opts.callbacks and (out.signal ~= 7 and out.signal ~= 9) then
        ---@type (fun(out: vim.SystemCompleted))[]
        local callbacks
        if vim.is_callable(opts.callbacks) then
            callbacks = {
                opts.callbacks --[[@as fun(out: vim.SystemCompleted) ]],
            }
        else
            callbacks = opts.callbacks --[[@as (fun(out: vim.SystemCompleted))[] ]]
        end

        for _, cb in ipairs(callbacks) do
            cb(out)
        end
    end
end

--- Execute cmd and fill the quickfix with results
---@param cmd string[]
---@param opts Report.Opts?
---@return vim.SystemObj
function M.report(cmd, opts)
    opts = opts or {}

    if opts.uniq == nil then
        opts.uniq = true
    end

    if opts.notify == nil then
        opts.notify = true
    end

    if opts.dump == nil then
        opts.dump = true
    end

    if opts.clear == nil then
        opts.clear = true
    end

    if (opts.win and type(opts.win) == type(true)) or (not opts.win and opts.buf) then
        opts.win = vim.api.nvim_get_current_win()
        opts.buf = opts.buf or vim.api.nvim_win_get_buf(opts.win --[[@as integer]])
    end

    ---@type vim.SystemOpts
    local user_opts = opts.opts or {}
    local origin_stdout = user_opts.stdout ---@type fun(err:string?, data: string?)|boolean
    local origin_stderr = user_opts.stderr ---@type fun(err:string?, data: string?)|boolean
    user_opts.stdout = nil
    user_opts.stderr = nil

    ---@type vim.SystemOpts
    local obj_opts = {
        cwd = vim.fs.normalize(vim.uv.cwd()),
        text = true,
    }
    vim.tbl_extend('force', obj_opts, user_opts)

    ---@type Data
    local state_data = { -- TODO: it may be good to use ringbuffer to limit the output
        stdout = {},
        stderr = {},
        output = {},
    }

    local hash = require('utils.async').get_hash(cmd, obj_opts.cwd)

    obj_opts.stdout = vim.schedule_wrap(function(err, data)
        process_data(err, data, hash, state_data.stdout, state_data.output, user_opts.text, origin_stdout)
    end)

    obj_opts.stderr = vim.schedule_wrap(function(err, data)
        process_data(err, data, hash, state_data.stderr, state_data.output, user_opts.text, origin_stderr)
    end)

    ---@type vim.SystemObj?
    if opts.uniq and ASYNC.tasks[hash] then
        ASYNC.tasks[hash]:kill(vim.uv.constants.SIGTERM)
    end

    -- TODO: Get the efm from the current buffer, the on_exit may be called on a different buffer
    if not opts.efm then
        opts.efm = vim.go.efm -- -- TODO: Check this?
    end

    local obj = vim.system(
        cmd,
        obj_opts,
        vim.schedule_wrap(function(out)
            process_exit(out, state_data, cmd, obj_opts.cwd, opts)
        end)
    )

    ASYNC.tasks[hash] = obj
    if opts.progress then
        require('utils.async').queue_progress_task(hash)
    end
    return obj
end

return M
