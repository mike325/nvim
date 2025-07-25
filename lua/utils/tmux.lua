local M = {}

function M.get_window_id(cb)
    local cmd = { 'tmux', 'display-message', '-p', '-F', '#{window_index}' }

    local function notify_error(out)
        local output = out.stdout .. '\n' .. out.stderr
        vim.notify('Failed to get current TMUX window:\n' .. output, vim.log.levels.ERROR, { title = 'TMUX' })
    end

    local tmux_task = vim.system(
        cmd,
        { text = true },
        vim.schedule_wrap(function(out)
            if cb then
                if out.code == 0 then
                    local wid = (out.stdout:gsub('\n', ''))
                    cb(wid)
                else
                    notify_error(out)
                end
            end
        end)
    )

    if not cb then
        local tmux_out = tmux_task:wait(30)
        if tmux_task.code ~= 0 then
            notify_error(tmux_task)
            return false
        end
        return (tmux_out.stdout:gsub('\n', ''))
    end
end

function M.split_window(cmd, cb)
    local function exec_cmd(id)
        local tmux_cmd = {
            'tmux',
            'split-window',
            '-d',
            '-Z',
            '-t',
            id,
        }

        if cmd then
            table.insert(tmux_cmd, table.concat(cmd, ' '))
        end
        RELOAD('utils.async').makeprg {
            makeprg = tmux_cmd,
            notify = true,
            open = false,
            jump = false,
            callbacks = cb
        }
    end

    M.get_window_id(exec_cmd)
end

return M
