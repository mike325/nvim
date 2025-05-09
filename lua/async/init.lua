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
--- @field stdin? string|string[]|true
--- @field stdout? fun(err:string?, data: string?)|false
--- @field stderr? fun(err:string?, data: string?)|false
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
---@field uniq (boolean?) Stop previous job before executing, default: true
---@field win (boolean|integer|nil) Use location list instead of quickfix
---@field opts (vim.SystemOpts?) Override default opts, default: {text = true}
---@field callbacks (fun(out: vim.SystemCompleted)|fun(out: vim.SystemCompleted)[]|nil)
---                 Callback executed after process qf default on_exit
-- TODO: Add progress support

--- Execute cmd and fill the quickfix with results
---@param cmd string[]
---@param opts Report.Opts?
---@return vim.SystemObj
function M.qf_report_job(cmd, opts)
    opts = opts or {}

    if opts.uniq == nil then
        opts.uniq = true
    end

    if opts.notify == nil then
        opts.notify = true
    end

    if opts.clear == nil then
        opts.clear = true
    end

    ---@type vim.SystemOpts
    local obj_opts = {
        cwd = vim.fs.normalize(vim.uv.cwd()),
        text = true,
    }

    ---@type vim.SystemOpts
    local user_opts = opts.opts or {}

    local origin_stdout = user_opts.stdout ---@type fun(err:string?, data: string?)
    local origin_stderr = user_opts.stderr ---@type fun(err:string?, data: string?)

    user_opts.stdout = nil
    user_opts.stderr = nil
    vim.tbl_extend('force', obj_opts, user_opts)
    local hash = require('utils.async').get_hash(cmd, obj_opts.cwd)

    ---@class Data
    ---@field stdout string[]
    ---@field stderr string[]
    ---@field output string[]
    local state_data = { -- TODO: it may be good to use ringbuffer to limit the output
        stdout = {},
        stderr = {},
        output = {},
    }

    ---@param err string
    ---@param data string
    local function output(err, data)
        if err then
            error(err)
        end
        if obj_opts.text and data then
            table.insert(state_data.output, (data:gsub('\r\n', '\n')))
        else
            table.insert(state_data.output, data)
        end
    end

    ---@param err string
    ---@param data string
    local function stdout(err, data)
        if err then
            error(err)
        end
        if obj_opts.text and data then
            table.insert(state_data.stdout, (data:gsub('\r\n', '\n')))
        else
            table.insert(state_data.stdout, data)
        end

        output(err, data)

        if origin_stdout then
            origin_stdout(err, data)
        end
    end

    ---@param err string
    ---@param data string
    local function stderr(err, data)
        if err then
            error(err)
        end
        if obj_opts.text and data then
            table.insert(state_data.stderr, (data:gsub('\r\n', '\n')))
        else
            table.insert(state_data.stderr, data)
        end

        output(err, data)

        if origin_stderr then
            origin_stderr(err, data)
        end
    end

    obj_opts.stdout = vim.schedule_wrap(stdout)
    obj_opts.stderr = vim.schedule_wrap(stderr)

    ---@type vim.SystemObj?
    if opts.uniq and ASYNC.jobs[hash] then
        ASYNC.jobs[hash]:kill(7)
    end

    ---@param out vim.SystemCompleted
    local function on_exit(out)
        out.stdout = out.stdout or table.concat(state_data.stdout, '\n')
        out.stderr = out.stderr or table.concat(state_data.stderr, '\n')

        ASYNC.output:push(out)
        ASYNC.jobs[hash] = nil

        local cmd_name = vim.basename(cmd[1])
        local ns_name = string.format('async.%s', cmd_name)
        local qf_utils = require 'utils.qf'

        if out.code == 0 then
            if opts.notify then
                vim.notify(string.format('cmd: %s succeed', cmd_name), vim.log.levels.INFO, { title = 'Async' })
            end

            if opts.clear then
                vim.diagnostic.reset(vim.api.nvim_create_namespace(ns_name))
                local qf = vim.fn.getqflist { context = 1 }

                if qf.context and type(qf.context) == type {} then
                    local qf_hash = require('utils.async').get_hash(qf.context.cmd, qf.context.cwd)
                    if qf_hash == hash then
                        qf_utils.clear(opts.win)
                    end
                end
            end
        elseif out.signal ~= 7 then
            local qf_opts = {
                items = state_data.output,
                context = {
                    ns_name = ns_name,
                    cmd = cmd,
                    cwd = obj_opts.cwd,
                },
            }
            if opts.append then
                qf_opts.action = 'a'
            end
            qf_utils.set_list(qf_opts, opts.win)
            qf_utils.qf_to_diagnostic(ns_name, opts.win)

            if not opts.silent then
                vim.notify(string.format('cmd: %s failed', cmd_name), vim.log.levels.ERROR, { title = 'Async' })
            end
        end

        -- NOTE: Don't process callbacks if the job was killed
        if opts.callbacks and out.signal ~= 7 then
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

    local obj = vim.system(cmd, obj_opts, vim.schedule_wrap(on_exit))
    ASYNC.jobs[hash] = obj

    return obj
end

return M
