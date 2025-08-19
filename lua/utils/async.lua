local M = {}

---Push output to the stack
---@param out vim.SystemCompleted
---@param cmd string[]
---@param cwd string?
function M.push_output(out, cmd, cwd)
    -- NOTE: don't push output of self cancel jobs
    if out.signal ~= 7 then
        ASYNC.output:push {
            cmd = cmd,
            cwd = cwd or vim.uv.cwd(),
            code = out.code,
            signal = out.signal,
            stdout = out.stdout,
            stderr = out.stderr,
        }
    end
end

--- Get string repr of the given cmd
---@param cmd string|string[]
---@param cwd string?
---@return string
function M.get_hash(cmd, cwd)
    cwd = cwd or vim.fs.normalize(vim.uv.cwd())
    local hash = vim.base64.encode(vim.json.encode { cmd = cmd, cwd = cwd })
    return hash
end

---Get active progress task
---@param hash string
function M.remove_progress_task(hash)
    local idx, _ = vim.iter(ASYNC.progress):enumerate():find(function(_, task)
        return hash == task.hash
    end)

    local task
    if idx then
        task = table.remove(ASYNC.progress, idx)
    end

    if #ASYNC.progress == 0 and vim.t.progress_win then
        vim.api.nvim_win_close(vim.t.progress_win, false)
    end

    return task
end

---Get active progress task
function M.get_progress_task()
    return ASYNC.progress[1]
end

---Get active progress task
---@param hash string
function M.queue_progress_task(hash)
    local current = M.get_progress_task() or {}
    local task = M.remove_progress_task(hash)
    if not ASYNC.tasks[hash] then
        return
    end

    if not current.hash or current.hash ~= (task or {}).hash then
        require('utils.windows').progress {}
    end
    table.insert(ASYNC.progress, 1, task or { hash = hash, task = ASYNC.tasks[hash] })
end

local function get_grepprg(opts)
    opts = opts or {}

    ---@type string[]
    local grepprg = vim.split(vim.bo.grepprg ~= '' and vim.bo.grepprg or vim.o.grepprg, '%s+', { trimempty = true })

    ---@type string|string[]
    local cmd = opts.cmd or grepprg[1]

    ---@type string[]
    local args = opts.args or {}

    vim.validate {
        cmd = { cmd, 'string' },
        args = { args, 'table' },
    }

    if cmd == grepprg[1] and #args == 1 then
        vim.list_extend(args, vim.list_slice(grepprg, 2, #grepprg))
    end

    cmd = type(cmd) == type '' and { cmd } or cmd

    args = vim.iter(args)
        :filter(function(arg)
            return not arg:match '^%s*$'
        end)
        :totable()

    local pathspec, search
    if vim.iter(args):find '%' then
        args = vim.iter(args)
            :filter(function(arg)
                return arg ~= '%'
            end)
            :totable()
        search = args[#args]
        pathspec = { vim.fn.expand '%' }
    elseif vim.iter(args):find '##' then
        args = vim.iter(args)
            :filter(function(arg)
                return arg ~= '##'
            end)
            :totable()
        search = args[#args]
        pathspec = vim.iter(vim.fn.argv()):filter(require('utils.files').is_file):totable()
    else
        search = vim.fn.expand '<cword>'
    end

    vim.list_extend(cmd, args)
    -- table.insert(cmd, search)
    if pathspec then
        vim.list_extend(cmd, pathspec)
    end

    return cmd, search
end

function M.grep(opts)
    local nvim = require 'nvim'

    vim.validate { opts = { opts, 'table', true } }

    opts = opts or {}

    ---@type string[]
    local cmd, search = get_grepprg(opts) --[[@as string[] ]]
    search = search or vim.fn.expand '<cword>'
    nvim.reg['/'] = search

    local use_loc = opts.loc
    local win
    if use_loc then
        win = opts.win or vim.api.nvim_get_current_win()
    end

    local efm = vim.o.grepformat
    local cwd = opts.cwd or vim.fs.normalize(vim.uv.cwd())

    vim.system(
        cmd,
        { text = true, cwd = cwd },
        vim.schedule_wrap(function(out)
            M.push_output(out, cmd, cwd)
            if out.code == 0 then
                if out.stdout == '' and out.stderr == '' then
                    vim.notify('No matching results ' .. search, vim.log.levels.WARN, { title = 'Grep' })
                else
                    local files = vim.split(out.stdout, '\n', { trimempty = true })
                    require('utils.qf').set_list { items = files, win = win, efm = efm, jump = true }
                end
            elseif out.code ~= 0 then
                if out.stdout == '' and out.stderr == '' then
                    vim.notify('No matching results ' .. search, vim.log.levels.WARN, { title = 'Grep' })
                else
                    vim.notify(
                        ('%s exited with code %s\n%s'):format(cmd[1], out.code, out.stderr),
                        vim.log.levels.ERROR,
                        { title = 'Grep' }
                    )
                end
            end
        end)
    )
end

--- @class Make
--- @field makeprg? string|string[]
--- @field args? string[]
--- @field efm? string|string[]
--- @field open? boolean
--- @field jump? boolean
--- @field notify? boolean
--- @field silent? boolean
--- @field dump? boolean
--- @field progress? boolean
--- @field win? boolean|number
---@field callbacks (fun(out: vim.SystemCompleted)|fun(out: vim.SystemCompleted)[]|nil)
---                 Callback executed after process qf default on_exit

--- @param opts Make?
function M.makeprg(opts)
    opts = opts or {}
    local args = opts.args or {}

    local makeprg = opts.makeprg
    if not makeprg then
        makeprg = vim.bo.makeprg
        if makeprg == '' then
            makeprg = vim.go.makeprg
        end
        makeprg = vim.split(makeprg, ' ', { trimempty = true })
    end

    ---@cast makeprg string[]
    local cmd = vim.list_extend(makeprg, args)
    cmd = vim.iter(cmd):map(vim.fn.expand):totable()
    vim.list_extend(cmd, args)

    local open = opts.open
    if open == nil then
        open = true
    end

    RELOAD('async').report(cmd, {
        open = open,
        notify = opts.notify,
        silent = opts.silent,
        jump = opts.jump,
        efm = opts.efm,
        win = opts.win,
        dump = opts.dump,
        progress = opts.progress,
        callbacks = opts.callbacks,
    })
end

function M.lint(linter, opts)
    vim.validate {
        linter = { linter, 'string' },
        opts = { opts, 'table', true },
    }

    opts = opts or {}

    local language = opts.language or opts.filetype or vim.bo.filetype
    local buf = opts.buf or vim.api.nvim_get_current_buf()
    local bufname = opts.bufname or opts.filename or vim.api.nvim_buf_get_name(buf)

    local function get_args(configs, configflag, fallback_args)
        if configs and configflag then
            local config_files = vim.fs.find(configs, { upward = true, type = 'file' })
            if config_files[1] then
                return { configflag, config_files[1] }
            end
        elseif opts.global_config and require('utils.files').is_file(opts.global_config) then
            return { configflag, opts.global_config }
        end

        return fallback_args
    end

    ---@type string[]
    local cmd = { linter }
    if opts.subcmd or opts.subcommand then
        table.insert(cmd, opts.subcmd or opts.subcommand)
    end

    ---@type string|string[]
    local efm = opts.efm or opts.errorformat
    if not efm then
        efm = vim.go.efm
    end

    local args
    local ft_linters = vim.F.npcall(RELOAD, 'filetypes.' .. language)
    if ft_linters and ft_linters.makeprg then
        local linter_data = ft_linters.makeprg[linter]
        if linter_data then
            args = linter_data
            efm = opts.efm or opts.errorformat or linter_data.efm or linter_data.errorformat or efm
        end
    end

    if type(efm) == type {} then
        efm = table.concat(efm --[[@as string[] ]], ',')
    end

    if opts.args then
        args = type(opts.args) == type {} and opts.args or { opts.args }
    end

    local extra_args = get_args(opts.configs, opts.config_flag, args or {})
    vim.list_extend(cmd, extra_args)
    table.insert(cmd, bufname)

    M.makeprg {
        makeprg = cmd,
        notify = false,
        silent = true,
        open = false,
        jump = false,
        dump = false,
        win = true,
        efm = efm,
    }
end

function M.formatprg(args)
    args = args or {}

    vim.validate {
        cmd = { args.cmd, 'table' },
        bufnr = { args.bufnr, 'number', true },
        first = { args.first, 'number', true },
        last = { args.last, 'number', true },
    }

    local cmd = args.cmd
    local bufnr = args.bufnr or vim.api.nvim_get_current_buf()

    local buf_utils = RELOAD 'utils.buffers'

    local first = args.first or (vim.v.lnum - 1)
    local last = args.last or (first + vim.v.count)

    local lines = vim.api.nvim_buf_get_lines(bufnr, first, last, false)
    local indent_level = buf_utils.get_indent_block_level(lines)
    local tmpfile = vim.fn.tempname()

    local ft = vim.filetype.match { buf = bufnr }
    if ft == 'robot' then
        tmpfile = string.format('%s.robot', tmpfile)
    end

    require('utils.files').writefile(tmpfile, buf_utils.indent(lines, -indent_level))
    table.insert(cmd, tmpfile)

    local view = vim.fn.winsaveview()
    local win = vim.api.nvim_get_current_win()

    vim.system(
        cmd,
        { text = true },
        vim.schedule_wrap(function(out)
            M.push_output(out, cmd)
            if out.code == 0 then
                local fmt_lines = require('utils.files').readfile(tmpfile)
                fmt_lines = buf_utils.indent(fmt_lines, indent_level)
                vim.api.nvim_buf_set_lines(bufnr, first, last, false, fmt_lines)
                vim.fn.winrestview(view)
            else
                local output = out.stderr ~= '' and out.stderr or out.stdout
                if output ~= '' then
                    require('utils.qf').set_list {
                        items = vim.split(output, '\n', { trimempty = true }),
                        win = win,
                        efm = args.efm,
                        open = true,
                        jump = false,
                    }
                else
                    vim.notify(
                        string.format('Failed to format buffer, code: %s', out.code),
                        vim.log.levels.ERROR,
                        { title = 'Formatter' }
                    )
                end
            end
        end)
    )
end

return M
