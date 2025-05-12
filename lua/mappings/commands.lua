local sys = require 'sys'
-- local nvim = require 'nvim'

local M = {}

--- Open a terminal buffer in a floating window
--- @param opts Command.Opts
function M.floating_terminal(opts)
    local cmd = opts.args
    local shell
    local executable = RELOAD('utils.files').executable

    if cmd ~= '' then
        shell = cmd
    elseif sys.name == 'windows' then
        if vim.regex([[^cmd\(\.exe\)\?$]]):match_str(vim.go.shell) then
            shell = 'powershell -noexit -executionpolicy bypass '
        else
            shell = vim.go.shell
        end
    else
        shell = vim.fn.fnamemodify(vim.env.SHELL or '', ':t')
        if vim.regex([[\(t\)\?csh]]):match_str(shell) then
            shell = executable 'zsh' and 'zsh' or (executable 'bash' and 'bash' or shell)
        end
    end

    local win = RELOAD('utils.windows').big_center()

    vim.wo[win].number = false
    vim.wo[win].relativenumber = false

    vim.fn.termopen(shell)

    if cmd ~= '' then
        vim.cmd.startinsert()
    end
end

--- Toggle mouse support
function M.toggle_mouse()
    if vim.o.mouse == '' then
        vim.o.mouse = 'a'
        print 'Mouse Enabled'
    else
        vim.o.mouse = ''
        print 'Mouse Disabled'
    end
end

--- Wrapper around edit command to resolve globs and other goodies
--- @param args Command.Opts
-- TODO: Support line numbers
function M.edit(args)
    local utils = RELOAD 'utils.files'
    local globs = args.fargs
    local cwd = vim.pesc(vim.uv.cwd() .. '/')
    for _, g in ipairs(globs) do
        if utils.is_file(g) then
            vim.cmd.edit((g:gsub(cwd, '')))
        elseif g:match '%*' then
            local files = vim.fn.glob(g, false, true, false)
            for _, f in ipairs(files) do
                if utils.is_file(f) then
                    vim.cmd.edit((f:gsub(cwd, '')))
                end
            end
        end
    end
end

function M.kill_task(pid)
    local async_task

    if not pid then
        local hashes = {}
        local cmds = {}
        for hash, task in pairs(ASYNC.tasks) do
            hashes[#hashes + 1] = hash
            local cmd = vim.json.decode(vim.base64.decode(hash)).cmd
            cmds[#cmds + 1] = ('%s: %s'):format(task.pid, table.concat(cmd, ' '))
        end
        if #cmds > 0 then
            vim.ui.select(
                cmds,
                { prompt = 'Select a cmd:' },
                vim.schedule_wrap(function(choice, idx)
                    if choice then
                        local hash = hashes[idx]
                        async_task = ASYNC.tasks[hash]
                        if async_task then
                            async_task:kill(7)
                        end
                    end
                end)
            )
            return
        else
            vim.notify('No tasks to kill', vim.log.levels.WARN, { title = 'Killtask' })
        end
    else
        for _, task in pairs(ASYNC.tasks) do
            if pid == task.pid then
                async_task = task
                break
            end
        end

        if not async_task then
            vim.notify('Could not find PID: ' .. pid, vim.log.levels.WARN, { title = 'Killtask' })
        end
    end

    if async_task then
        async_task:kill(7)
    end
end

return M
