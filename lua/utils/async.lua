local M = {}

function M.grep(opts)
    local nvim = require 'nvim'

    vim.validate {
        opts = { opts, 'table', true },
    }

    opts = opts or {}

    local grepprg = vim.bo.grepprg ~= '' and vim.bo.grepprg or vim.o.grepprg
    grepprg = vim.split(grepprg, '%s+', { trimempty = true })

    local cmd = opts.cmd or grepprg[1]
    local args = opts.args or {}
    local search = opts.search or vim.fn.expand '<cword>'
    -- NOTE: Save the search in / for future reference,
    nvim.reg['/'] = search
    local use_loc = opts.loc

    vim.validate {
        cmd = { cmd, 'string' },
        args = { args, 'table' },
        search = { search, 'string' },
        use_loc = { use_loc, 'boolean', true },
    }

    if cmd == grepprg[1] and #args == 0 then
        vim.list_extend(args, vim.list_slice(grepprg, 2, #grepprg))
    end

    local win
    if use_loc then
        win = opts.win or vim.api.nvim_get_current_win()
    end

    if type(cmd) ~= type {} then
        cmd = { cmd }
    end
    args = vim.tbl_filter(function(k)
        return not k:match '^%s*$'
    end, args)

    vim.list_extend(cmd, args)
    table.insert(cmd, search)

    local grep = RELOAD('jobs'):new {
        cmd = cmd,
        silent = true,
        opts = {
            cwd = vim.fs.normalize(vim.uv.cwd()),
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
