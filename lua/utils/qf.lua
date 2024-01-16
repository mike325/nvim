local nvim = require 'nvim'

local M = {}

local qf_funcs = {
    first = function(win)
        vim.validate {
            win = { win, { 'number', 'boolean' }, true },
        }
        if win then
            vim.cmd.lfirst()
        else
            vim.cmd.cfirst()
        end
    end,
    last = function(win)
        vim.validate {
            win = { win, { 'number', 'boolean' }, true },
        }
        if win then
            vim.cmd.llast()
        else
            vim.cmd.clast()
        end
    end,
    open = function(win, size)
        vim.validate {
            win = { win, { 'number', 'boolean' }, true },
            size = { size, 'number', true },
        }
        local cmd = win and 'lopen' or 'copen'
        -- TODO: botright and topleft does not seem to work with vim.cmd, need some digging
        -- TODO: for some reason vim.cmd.copen/lopen does not accept arguments
        if win then
            vim.cmd { cmd = cmd, count = size or nil }
        else
            local direction = vim.o.splitbelow and 'botright' or 'topleft'
            vim.cmd { cmd = cmd, count = size or nil, mods = { split = direction } }
        end
    end,
    close = function(win)
        vim.validate {
            win = { win, { 'number', 'boolean' }, true },
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
            win = { win, { 'number', 'boolean' }, true },
        }
        items = items or {}
        if win then
            if type(win) == type(true) or win == 0 then
                win = vim.api.nvim_get_current_win()
            end
            -- BUG: For some reason we cannot send what as nil, so it needs to be omitted
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
            win = { win, { 'number', 'boolean' }, true },
        }
        if type(what) == type(1) then
            assert(type(what) ~= type(win), debug.traceback 'Win and What cannot be both Numbers')
            win = what
            what = nil
        end
        if win then
            if type(win) == type(true) or win == 0 then
                win = vim.api.nvim_get_current_win()
            end
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
        win = { win, { 'number', 'boolean' }, true },
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
    vim.validate { win = { win, { 'number', 'boolean' }, true } }
    qf_funcs.close(win)
end

function M.get_list(what, win)
    return qf_funcs.get_list(what, win)
end

function M.set_list(opts, win)
    vim.validate {
        opts = { opts, 'table' },
        items = { opts.items, 'table' },
        win = { win, { 'number', 'boolean' }, true },
        action = { opts.action, 'string', true },
        open = { opts.open, 'boolean', true },
        jump = { opts.jump, 'boolean', true },
        efm = { opts.efm, { 'string', 'table' }, true },
    }

    assert(not opts.lines, debug.traceback 'Cannot set lines using items')

    vim.validate { win = { opts.win, { 'number', 'boolean' }, true } }
    if not win and opts.win then
        win = opts.win
        opts.win = nil
    end

    if win and type(win) == type(true) then
        win = vim.api.nvim_get_current_win()
    end

    local action = opts.action or ' '
    local items = opts.items
    local open = opts.open
    local jump = opts.jump

    opts.items = nil
    opts.action = nil
    opts.open = nil
    opts.jump = nil

    local function fix_line(line)
        local BIG_LINE = 256
        if #line > BIG_LINE then
            line = (line:sub(1, BIG_LINE)) .. '...>'
        end
        return vim.api.nvim_replace_termcodes(line, true, false, false)
    end

    -- NOTE: quickfix is extremely slow to parse long items and actually freezes neovim
    --       this hack truncate all big elements to speed up parsing
    local function short_long_lines(qf_items)
        if type(qf_items[1]) == type '' then
            -- list of elements, not parsed yet
            qf_items = require('utils.tables').clear_lst(qf_items)
            for idx, line in ipairs(qf_items) do
                qf_items[idx] = fix_line(line)
            end
        else
            -- list of item, already parse
            for idx, line in ipairs(qf_items) do
                if line.text then
                    qf_items[idx].text = fix_line(line.text)
                end
            end
        end
        return qf_items
    end

    if type(items[1]) == type {} then
        opts.items = short_long_lines(items)
    elseif type(items[1]) == type '' then
        opts.lines = short_long_lines(require('utils.tables').clear_lst(items))
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
    else
        error(debug.traceback('Invalid items type: ' .. type(items[1])))
    end

    if #(opts.items or opts.lines) == 0 then
        vim.notify('No items to display', vim.log.levels.ERROR, { title = win and 'LocationList' or 'QuickFix' })
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

function M.qf_to_diagnostic(ns, win)
    vim.validate {
        ns = { ns, { 'number', 'string' }, true },
        win = { win, { 'number', 'boolean' }, true },
    }

    local qf = qf_funcs.get_list({ items = 1, title = 1 }, win)

    local ns_name
    if not ns or type(ns) == type '' then
        if (not ns and qf.title == '') or (ns == '' and qf.title == '') then
            error(debug.traceback 'Missing namespace or Qf Title')
        end
        if not ns or ns == '' then
            ns = qf.title
        end
        ns_name = ns:gsub('%s+', '_'):lower()
        ns = vim.api.nvim_create_namespace(ns_name)
    else
        for namespace, ns_nr in pairs(vim.api.nvim_get_namespaces()) do
            if ns_nr == ns then
                ns_name = namespace
                break
            end
        end
        if not ns_name then
            error(debug.traceback(string.format('Invalid NS number %d', ns)))
        end
    end
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
                    once = true,
                    callback = function()
                        vim.diagnostic.set(ns, buf, diagnostic)
                        vim.diagnostic.show(ns, buf)
                    end,
                })
            end
        end
    end
end

function M.diagnostics_to_qf(diagnostics, opts, win)
    vim.validate {
        diagnostics = { diagnostics, 'table' },
        opts = { opts, 'table', true },
        win = { win, { 'number', 'boolean' }, true },
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
        win = { win, { 'number', 'boolean' }, true },
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
        opts = { opts, { 'table', 'number' }, true },
        win = { win, { 'number', 'boolean' }, true },
    }

    if type(opts) == 'number' then
        if not win then
            win = opts
            opts = {}
        else
            error(debug.traceback 'Cannot provide opts = "number" and win = "number"')
        end
    end

    opts = opts or {}

    vim.validate { win = { opts.win, 'number', true } }
    if not win and opts.win then
        win = opts.win
        opts.win = nil
    end

    local items = {}
    for _, buf in ipairs(buffers) do
        local filename = type(buf) == type(1) and vim.api.nvim_buf_get_name(buf) or buf
        local item = { valid = true, lnum = 1, col = 1, text = filename }
        if type(buf) == type(1) then
            item.bufnr = buf
        elseif type(buf) == type '' then
            item.filename = buf
        else
            error(debug.traceback('Invalid data type: ' .. type(buf)))
        end
        table.insert(items, item)
    end
    if #items > 0 then
        opts.items = items
        if opts.open == nil then
            opts.open = true
        end

        M.set_list(opts, win)

        if opts.jump then
            qf_funcs.first(win)
        end
    else
        vim.notify('No buffers to dump', vim.log.levels.INFO)
    end
end

function M.filter_qf_diagnostics(opts, win)
    opts = opts or {}
    vim.validate {
        level = { opts.level, 'string' },
        win = { win, { 'number', 'boolean' }, true },
    }

    vim.validate { win = { opts.win, { 'number', 'boolean' }, true } }
    if not win and opts.win then
        win = opts.win
        opts.win = nil
    end

    local level = opts.level:upper()

    local filtered_list = {}
    local qf = qf_funcs.get_list({ all = 0 }, win)

    if not vim.log.levels[level] then
        vim.notify('Invalid level: ' .. opts.args, vim.log.levels.ERROR, { title = 'QFDiagnostics' })
        return
    end

    level = level:sub(1, 1)

    local translation_list = {}
    for l, v in pairs(vim.lsp.log_levels) do
        if type(l) == type(0) then
            translation_list[l] = v:sub(1, 1)
        else
            translation_list[l:sub(1, 1)] = v
        end
    end

    for _, item in ipairs(qf.items) do
        if item.type == level or (opts.bang and translation_list[item.type] >= translation_list[level]) then
            table.insert(filtered_list, item)
        end
    end

    local new_qf = {
        title = qf.title,
        items = filtered_list,
    }

    M.set_list(new_qf, win)
end

function M.qf_loclist_switcher(opts)
    opts = opts or {}
    local loc = opts.loc
    local win = vim.api.nvim_get_current_win()

    local src = loc and 'Qf' or 'LocList'
    local dest = loc and 'Loclist' or 'Qf'

    local qflist = M.get_list({ items = true, winid = true, title = true, context = true }, not loc and win or nil)
    if #qflist.items > 0 then
        local is_open = M.is_open(not loc and win or nil)
        M.set_list(qflist, loc and win or nil)
        M.clear(not loc and win or nil)
        if is_open then
            M.open(loc and win or nil)
        end
    else
        vim.notify(src .. ' is empty!, nothing to set in the ' .. dest, vim.log.levels.WARN)
    end
end

function M.qf_to_arglist(opts)
    opts = opts or {}
    local loc = opts.loc
    local win = opts.win
    if loc and not win then
        win = vim.api.nvim_get_current_win()
    end
    local qfitems = M.get_list({ items = true }, win).items
    local files = {}
    for _, item in ipairs(qfitems) do
        local buf = item.bufnr
        if buf and vim.api.nvim_buf_is_valid(buf) then
            table.insert(files, buf)
        end
    end
    RELOAD('utils.arglist').add(files, true)
end

return M
