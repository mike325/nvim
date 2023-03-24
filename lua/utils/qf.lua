local nvim = require 'nvim'

local M = {}

local qf_funcs = {
    first = function(win)
        vim.validate {
            win = { win, 'number', true },
        }
        if win then
            vim.cmd.lfirst()
        else
            vim.cmd.cfirst()
        end
    end,
    last = function(win)
        vim.validate {
            win = { win, 'number', true },
        }
        if win then
            vim.cmd.llast()
        else
            vim.cmd.clast()
        end
    end,
    open = function(win, size)
        vim.validate {
            win = { win, 'number', true },
            size = { size, 'number', true },
        }
        local cmd = win and 'lopen' or 'copen'
        -- TODO: botright and topleft does not seem to work with vim.cmd, need some digging
        -- TODO: for some reason vim.cmd.copen/lopen does not accept arguments
        if win then
            vim.cmd(('%s %s'):format(cmd, size or ''))
        else
            local direction = vim.o.splitbelow and 'botright' or 'topleft'
            vim.cmd(('%s %s %s'):format(direction, cmd, size or ''))
        end
    end,
    close = function(win)
        vim.validate {
            win = { win, 'number', true },
        }
        if win then
            vim.cmd.lclose()
        else
            vim.cmd.cclose()
        end
    end,
    set_list = function(items, action, what, win)
        vim.validate {
            items = { items, 'table', true },
            action = { action, 'string' },
            what = { what, 'table', true },
            win = { win, 'number', true },
        }
        items = items or {}
        if win then
            -- BUG: For some reason we cannot send what as nil, so it needs to be ommited
            win = win == 0 and vim.api.nvim_get_current_win() or win
            if not what then
                vim.fn.setloclist(win, items, action)
            else
                vim.fn.setloclist(win, items, action, what)
            end
        else
            if not what then
                vim.fn.setqflist(items, action)
            else
                vim.fn.setqflist(items, action, what)
            end
        end
    end,
    get_list = function(what, win)
        vim.validate {
            what = { what, { 'table', 'number' }, true },
            win = { win, 'number', true },
        }
        if type(what) == type(1) then
            assert(type(what) ~= type(win), debug.traceback 'Win and What cannot be both Numbers')
            win = what
            what = nil
        end
        if win then
            win = win == 0 and vim.api.nvim_get_current_win() or win
            if what then
                return vim.fn.getloclist(win, what)
            end
            return vim.fn.getloclist(win)
        end
        if what then
            return vim.fn.getqflist(what)
        end
        return vim.fn.getqflist()
    end,
}

function M.clear(win)
    qf_funcs.set_list({}, ' ', nil, win)
    qf_funcs.close(win)
end

function M.is_open(win)
    local qf_winid = qf_funcs.get_list({ winid = 0 }, win).winid
    return qf_winid > 0
end

function M.open(size, win)
    vim.validate {
        size = { size, 'number', true },
        win = { win, 'number', true },
    }

    if not size then
        -- TODO: should this count only valid entries?
        local elements = qf_funcs.get_list({ size = 0 }, win).size + 1
        local lines = vim.opt_local.lines:get()
        size = math.min(math.floor(lines * 0.5), elements)
    end

    qf_funcs.open(win, size)
    -- vim.cmd.wincmd 'p'
end

function M.close(win)
    vim.validate { win = { win, 'number', true } }
    qf_funcs.close(win)
end

function M.get_list(what, win)
    return qf_funcs.get_list(what, win)
end

function M.set_list(opts, win)
    vim.validate {
        opts = { opts, 'table' },
        items = { opts.items, 'table' },
        win = { win, 'number', true },
        action = { opts.action, 'string', true },
        open = { opts.open, 'boolean', true },
        jump = { opts.jump, 'boolean', true },
    }

    assert(not opts.lines, debug.traceback 'Cannot set lines using items')

    vim.validate { win = { opts.win, 'number', true } }
    if not win and opts.win then
        win = opts.win
        opts.win = nil
    end

    local action = opts.action or ' '
    local items = opts.items
    local open = opts.open
    local jump = opts.jump

    opts.items = nil
    opts.action = nil
    opts.open = nil
    opts.jump = nil

    if type(items[1]) == type {} then
        opts.items = items
    elseif type(items[1]) == type '' then
        opts.lines = require('utils.tables').clear_lst(items)
        if not opts.efm or #opts.efm == 0 then
            local efm = vim.opt_local.efm:get()
            if #efm == 0 then
                efm = vim.opt_global.efm:get()
            end
            opts.efm = efm
        end

        if type(opts.efm) == type {} then
            opts.efm = table.concat(opts.efm, ',')
        end

        for idx, line in ipairs(opts.lines) do
            opts.lines[idx] = vim.api.nvim_replace_termcodes(line, true, false, false)
        end
    else
        error(debug.traceback('Invalid items type: ' .. type(items[1])))
    end

    if #(opts.items or opts.lines) == 0 then
        vim.notify('No items to display', 'ERROR', { title = win and 'LocationList' or 'QuickFix' })
        return
    end

    qf_funcs.set_list({}, action, opts, win)
    if jump then
        qf_funcs.first(win)
    end

    if open then
        M.open(nil, win)
    end
end

function M.qf_to_diagnostic(ns_name, win)
    vim.validate {
        ns_name = { ns_name, 'string', true },
        win = { win, 'number', true },
    }

    local qf = qf_funcs.get_list({ items = 1, title = 1 }, win)

    assert((ns_name and ns_name ~= '') or qf.title ~= '', debug.traceback 'Missing namespace or Qf Title')
    ns_name = ns_name or qf.title
    ns_name = ns_name:gsub('%s+', '_')
    local ns = vim.api.nvim_create_namespace(ns_name:lower())
    vim.diagnostic.reset(ns)
    if #qf.items > 0 then
        local diagnostics = vim.diagnostic.fromqflist(qf.items)
        if not diagnostics or #diagnostics == 0 then
            return
        end

        local buf_diagnostics = {}

        for _, diagnostic in ipairs(diagnostics) do
            local bufnr = tostring(diagnostic.bufnr)
            if not buf_diagnostics[bufnr] then
                buf_diagnostics[bufnr] = {}
            end
            table.insert(buf_diagnostics[bufnr], diagnostic)
        end

        for buf, diagnostic in pairs(buf_diagnostics) do
            buf = tonumber(buf)
            if vim.api.nvim_buf_is_loaded(buf) then
                vim.diagnostic.set(ns, buf, diagnostic)
                vim.diagnostic.show(ns, buf)
            else
                nvim.autocmd.add('BufEnter', {
                    group = 'Diagnostics' .. ns_name,
                    buffer = buf,
                    callback = function()
                        vim.diagnostic.set(ns, buf, diagnostics)
                        vim.diagnostic.show(ns, buf)
                    end,
                    once = true,
                })
            end
        end
        -- vim.diagnostic.show(ns)
    end
end

function M.diagnostics_to_qf(diagnostics, opts, win)
    vim.validate {
        diagnostics = { diagnostics, 'table' },
        opts = { opts, 'table', true },
        win = { win, 'number', true },
    }
    opts = opts or {}
    opts.items = {}
    win = win or opts.win
    for _, diagnostic in pairs(diagnostics) do
        local items = vim.diagnostic.toqflist(diagnostic)
        for idx, _ in ipairs(items) do
            items[idx].valid = 1
        end
        vim.list_extend(opts.items, items)
    end
    vim.api.nvim_win_set_buf(0, tonumber(vim.tbl_keys(diagnostics)[1]))
    M.set_list(opts, win)
    if not M.is_open(win) then
        M.open(win)
    end
end

function M.toggle(opts, win)
    vim.validate {
        opts = { opts, 'table', true },
        win = { win, 'number', true },
    }
    opts = opts or {}

    vim.validate { win = { opts.win, 'number', true } }
    if not win and opts.win then
        win = opts.win
        opts.win = nil
    end

    if M.is_open(win) then
        qf_funcs.close(win)
    else
        M.open(opts.size, win)
    end
end

function M.dump_files(buffers, opts, win)
    vim.validate {
        buffers = { buffers, 'table' },
        opts = { opts, { 'table', 'boolean' }, true },
        win = { win, 'number', true },
    }

    opts = opts or {}

    local open = opts.open
    opts.open = nil

    vim.validate { win = { opts.win, 'number', true } }
    if not win and opts.win then
        win = opts.win
        opts.win = nil
    end

    local items = {}
    for _, buf in ipairs(buffers) do
        if type(buf) == type(1) then
            table.insert(items, { bufnr = buf, valid = true })
        else
            table.insert(items, { filename = buf, valid = true })
        end
    end
    if #items > 0 then
        opts.items = items
        opts.open = open
        M.set_list(opts, win)
    else
        vim.notify('No buffers to dump', 'INFO')
    end
end

function M.filter_qf_diagnostics(opts, win)
    opts = opts or {}
    vim.validate {
        limit = { opts.limit, 'string' },
        win = { win, 'number', true },
    }

    vim.validate { win = { opts.win, 'number', true } }
    if not win and opts.win then
        win = opts.win
        opts.win = nil
    end

    local limit = opts.limit:upper()

    local filtered_list = {}
    local qf = qf_funcs.get_list({ all = 0 }, win)

    if not vim.log.levels[limit] then
        vim.notify('Invalid level: ' .. opts.args, 'ERROR', { title = 'QFDiagnostics' })
        return
    end

    limit = limit:sub(1, 1)

    local translation_list = {}
    for l, v in pairs(vim.lsp.log_levels) do
        if type(l) == type(0) then
            translation_list[l] = v:sub(1, 1)
        else
            translation_list[l:sub(1, 1)] = v
        end
    end

    for _, item in ipairs(qf.items) do
        if item.type == limit or (opts.bang and translation_list[item.type] >= translation_list[limit]) then
            table.insert(filtered_list, item)
        end
    end

    local new_qf = {
        title = qf.title,
        context = qf.context,
        items = filtered_list,
    }

    M.set_list(new_qf, win)
end

function M.dump_to_qf(opts)
    vim.validate {
        opts = { opts, 'table' },
        lines = { opts.lines, 'table' },
        context = { opts.context, 'string', true },
        title = { opts.title, 'string', true },
        efm = {
            opts.efm,
            function(e)
                return not e or type(e) == type '' or type(e) == type {}
            end,
            'error format must be a string or a table',
        },
    }

    opts.title = opts.title or opts.context or 'Generic Qf data'
    opts.context = opts.context or opts.title or 'GenericQfData'
    if not opts.efm or #opts.efm == 0 then
        local efm = vim.opt_local.efm:get()
        if #efm == 0 then
            efm = vim.opt_global.efm:get()
        end
        opts.efm = efm
    end

    if type(opts.efm) == type {} then
        opts.efm = table.concat(opts.efm, ',')
    end
    -- opts.efm = opts.efm:gsub(' ', '\\ ')

    local qf_type = opts.loc and 'loc' or 'qf'
    local qf_open = opts.open or false
    local qf_jump = opts.jump or false

    opts.loc = nil
    opts.open = nil
    opts.jump = nil
    opts.cmdname = nil
    opts.on_fail = nil
    opts.lines = require('utils.tables').clear_lst(opts.lines)

    for idx, line in ipairs(opts.lines) do
        opts.lines[idx] = vim.api.nvim_replace_termcodes(line, true, false, false)
    end

    local win
    if qf_type ~= 'qf' then
        win = opts.win or vim.api.nvim_get_current_win()
    end
    opts.win = nil
    qf_funcs.set_list({}, ' ', opts, win)

    local info_tab = opts.tab
    if info_tab and info_tab ~= nvim.get_current_tabpage() then
        vim.notify(
            ('%s Updated! with %s info'):format(qf_type == 'qf' and 'Qf' or 'Loc', opts.context),
            'INFO',
            { title = qf_type == 'qf' and 'QuickFix' or 'LocationList' }
        )
        return
    elseif #opts.lines > 0 then
        if qf_open then
            local elements = #qf_funcs.get_list(nil, win) + 1
            local lines = vim.opt.lines:get()
            local size = math.min(math.floor(lines * 0.5), elements)
            qf_funcs.open(win, size)
        end

        if qf_jump then
            qf_funcs.first(win)
        end
    else
        vim.notify('No output to display', 'ERROR', { title = qf_type == 'qf' and 'QuickFix' or 'LocationList' })
    end
end

return M
