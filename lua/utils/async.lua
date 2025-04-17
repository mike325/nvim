local M = {}

function M.get_hash(cmd, cwd)
    local cwd = cwd or vim.fs.normalize(vim.uv.cwd())
    local hash = vim.base64.encode(vim.json.encode { cmd = cmd, cwd = cwd })
    return hash
end

function M.exec(cmd, opts, args)
    opts = opts or { text = true }

    local hash = M.get_hash(cmd, opts.cwd)

    if STORAGE.async[hash] and args.uniq ~= false then
        local job = STORAGE.async[hash]
        job:kill(7)
        -- vim.api.nvim_create_augroup('Makeprg', { clear = true })
    end

    -- TODO: Wrap this functions using a function wrapper
    local output = { stdout = '', stderr = '' }
    local origin_stdout = opts.stdout

    local function stdout(err, data)
        if err == '' then
            output.stdout = output.stdout .. data
        end
        if vim.is_callable(origin_stdout) then
            origin_stdout(err, data)
        end
    end
    if opts.stdout ~= false then
        opts.stdout = vim.schedule_wrap(stdout)
    end

    local origin_stderr = opts.stderr
    local function stderr(err, data)
        if err == '' then
            output.stderr = output.stderr .. data
        end
        if vim.is_callable(origin_stderr) then
            origin_stderr(err, data)
        end
    end
    if opts.stderr ~= false then
        opts.stderr = vim.schedule_wrap(stderr)
    end

    local function on_exit(job)
        job.stdout = job.stdout or output.stdout
        job.stder = job.stderr or output.stderr

        if args.on_exit then
            args.on_exit(job)
        end

        STORAGE.async[hash] = nil
    end

    local job = vim.system(cmd, opts, vim.schedule_wrap(on_exit))
    STORAGE.async[hash] = job
    return job
end

local function get_grepprg(opts)
    local grepprg = vim.bo.grepprg ~= '' and vim.bo.grepprg or vim.o.grepprg
    grepprg = vim.split(grepprg, '%s+', { trimempty = true })

    local cmd = opts.cmd or grepprg[1]
    local args = opts.args or {}
    local search = opts.search or vim.fn.expand '<cword>'

    vim.validate {
        cmd = { cmd, 'string' },
        args = { args, 'table' },
        search = { search, 'string' },
    }

    if cmd == grepprg[1] and #args == 0 then
        vim.list_extend(args, vim.list_slice(grepprg, 2, #grepprg))
    end

    if type(cmd) ~= type {} then
        cmd = { cmd }
    end
    args = vim.tbl_filter(function(k)
        return not k:match '^%s*$'
    end, args)

    vim.list_extend(cmd, args)
    table.insert(cmd, search)

    return cmd
end

function M.grep(opts)
    local nvim = require 'nvim'

    vim.validate { opts = { opts, 'table', true } }

    opts = opts or {}
    local cmd = get_grepprg(opts)

    local search = opts.search or vim.fn.expand '<cword>'
    nvim.reg['/'] = search

    local use_loc = opts.loc
    local win
    if use_loc then
        win = opts.win or vim.api.nvim_get_current_win()
    end

    local cwd = opts.cwd or vim.fs.normalize(vim.uv.cwd())
    local grep = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        opts = {
            cwd = cwd,
            stdin = 'null',
        },
        qf = {
            on_fail = {
                open = true,
                jump = false,
            },
            loc = use_loc,
            win = win,
            jump = true,
            title = 'AsyncGrep',
            efm = vim.opt.grepformat:get(),
        },
    }

    grep:add_callbacks(function(job, rc)
        if rc == 0 and job:is_empty() then
            vim.notify('No matching results ' .. search, vim.log.levels.WARN, { title = 'Grep' })
        elseif rc ~= 0 then
            if job:is_empty() then
                vim.notify('No matching results ' .. search, vim.log.levels.WARN, { title = 'Grep' })
            else
                vim.notify(('%s exited with code %s'):format(cmd[1], rc), vim.log.levels.ERROR, { title = 'Grep' })
            end
        end
    end)
    grep:start()
end

return M
