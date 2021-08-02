local nvim = require'neovim'

local M = {}

function M.last_position()
    local sc_mark   = nvim.buf.get_mark(0, "'")
    local dc_mark   = nvim.buf.get_mark(0, '"')
    local last_line = nvim.fn.line('$')
    local filetype  = nvim.bo.filetype

    local black_list = {
        git = 1,
        gitcommit = 1,
        fugitive = 1,
        qf = 1,
    }

    if sc_mark[1] >= 1 and dc_mark[1] <= last_line and black_list[filetype] == nil then
        nvim.win.set_cursor(0, dc_mark)
    end
end

function M.bufloaded(bufnr)
    -- assert(type(bufnr) == type(1) and bufnr > 0, 'Invalid buffer')
    return vim.fn.bufloaded(bufnr) == 1
end

function M.is_modified(bufnr)
    assert(not bufnr or (type(bufnr) == type(1) and bufnr > 0), 'Invalid buffer')
    bufnr = bufnr or nvim.get_current_buf()
    return nvim.buf.get_option(bufnr, 'modified')
end

function M.delete(buffer, wipe)
    assert(not buffer or (type(buffer) == type(1) and buffer > 0), 'Invalid buffer')
    buffer = buffer or nvim.get_current_buf()
    local is_wipe = nvim.buf.get_option(buffer, 'bufhidden') == 'wipe'
    local prev_buf = vim.fn.expand('#') ~= '' and vim.fn.bufnr(vim.fn.expand('#')) or -1
    local is_loaded = nvim.buf.is_loaded

    if nvim.get_current_buf() == buffer then
        local new_view = is_loaded(prev_buf) and prev_buf or nvim.create_buf(true, false)
        nvim.win.set_buf(0, new_view)
    end

    if not is_wipe then
        local action = not wipe and {unload = true} or {force = true}
        nvim.buf.delete(buffer, action)
    end
end

function M.get_option(option, default)
    local ok, opt = pcall(nvim.buf.get_option, 0, option)
    if not ok then
        ok, opt = pcall(nvim.get_option, 0, option)
        if not ok then
            opt = default
        end
    end
    return opt
end

function M.get_indent()
    local indent = vim.opt_local.softtabstop:get()
    if indent <= 0 then
        indent = vim.opt_local.shiftwidth:get()
        if indent == 0 then
            indent = vim.opt_local.tabstop:get()
        end
    end
    return indent
end

function M.get_indent_block(lines)
    assert(vim.tbl_islist(lines) and #lines > 0, debug.traceback('Lines must be an array'))

    local indent_level
    for _,line in pairs(lines) do
        if #line > 0 then
            local level = line:match('^%s+')
            level = level and #level or nil
            if not level then
                indent_level = 0
                break
            elseif not indent_level or level < indent_level then
                indent_level = level
            end
        end
    end
    return indent_level or 0
end

function M.get_indent_string(indent)
    assert(not indent or (type(indent) == type(0) and indent > 0), 'Invalid indent number')
    local expand = vim.opt_local.expandtab:get()
    indent = indent or M.get_indent()
    local spaces = not expand and '\t' or string.rep(' ', indent)
    return spaces
end

local function normalize_indent(lines, indent)
    local expand = vim.opt_local.expandtab:get()
    local spaces = M.get_indent_string(indent)

    for i=1,#lines do
        if #lines[i] > 0 and not lines[i]:match('^%s+$') then
            if expand then
                lines[i] = lines[i]:gsub('\t', spaces)
            else
                lines[i] = lines[i]:gsub(spaces, '\t')
            end
        end
    end

    return lines
end

function M.indent(lines, level)
    assert(vim.tbl_islist(lines) and #lines > 0, debug.traceback('Lines must be an array'))
    assert(
        type(level) == type(0) and level ~= 0,
        debug.traceback('Missing valid level, cannot indent to level 0')
    )

    abslevel = math.abs(level)

    local indent = M.get_indent()
    local expand = vim.opt_local.expandtab:get()

    lines = normalize_indent(lines, abslevel)

    local spaces = not expand and string.rep('\t', abslevel) or string.rep(' ', indent*abslevel)

    if level < 0 then
        local block_indent = M.get_indent_block(lines)
        if block_indent == 0 then
            return lines
        else
            if not expand then
                block_indent = block_indent * indent
            end

            if block_indent < abslevel*indent then
                return lines
            end
        end
        spaces = '^'..spaces
    end

    for i=1,#lines do
        if #lines[i] > 0 and not lines[i]:match('^%s+$') then
            if level < 0 then
                lines[i] = lines[i]:gsub(spaces, '')
            else
                lines[i] = spaces..lines[i]
            end
        end
    end

    return lines
end

return M
