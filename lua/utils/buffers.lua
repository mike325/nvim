local nvim = require 'neovim'

local M = {}

function M.last_position()
    local sc_mark = nvim.buf.get_mark(0, "'")
    local dc_mark = nvim.buf.get_mark(0, '"')
    local last_line = nvim.fn.line '$'
    local filetype = nvim.bo.filetype

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
    vim.validate { buffer = { bufnr, 'number' } }

    return vim.fn.bufloaded(bufnr) == 1
end

function M.is_modified(bufnr)
    vim.validate { buffer = { bufnr, 'number', true } }

    bufnr = bufnr or nvim.get_current_buf()
    return nvim.buf.get_option(bufnr, 'modified')
end

function M.delete(bufnr, wipe)
    vim.validate { buffer = { bufnr, 'number', true }, wipe = { wipe, 'boolean', true } }
    assert(not bufnr or bufnr > 0, debug.traceback 'Buffer must be greater than 0')

    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local is_duplicated = false
    local is_wipe = nvim.buf.get_option(bufnr, 'bufhidden') == 'wipe'
    local prev_buf = vim.fn.expand '#' ~= '' and vim.fn.bufnr(vim.fn.expand '#') or -1
    prev_buf = prev_buf == bufnr and -1 or prev_buf

    if prev_buf == -1 then
        local wins = nvim.tab.list_wins(0)
        if #wins > 1 then
            local current_win = nvim.get_current_win()
            for _, win in pairs(wins) do
                local buf = nvim.win.get_buf(win)
                if win ~= current_win and buf ~= bufnr then
                    prev_buf = buf
                    break
                end
            end
        end
        local bufs = nvim.list_bufs()
        if #bufs > 1 and prev_buf == -1 then
            for _, buf in pairs(bufs) do
                if nvim.buf.is_loaded(buf) and buf ~= bufnr then
                    prev_buf = buf
                    break
                end
            end
        end
    end

    -- TODO: Don't create multiple empty buffers just do nothing here if buf == [No Name]
    if nvim.get_current_buf() == bufnr then
        local new_view = nvim.buf.is_loaded(prev_buf) and prev_buf or nvim.create_buf(true, false)
        nvim.win.set_buf(0, new_view)
    end

    for _, tab in pairs(nvim.list_tabpages()) do
        for _, win in pairs(nvim.tab.list_wins(tab)) do
            if nvim.win.get_buf(win) == bufnr then
                is_duplicated = true
                break
            end
        end
    end

    if not is_duplicated and not is_wipe and nvim.buf.is_valid(bufnr) then
        local action = not wipe and { unload = true } or { force = true }
        nvim.buf.delete(bufnr, action)
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
    vim.validate { lines = { lines, 'table' } }
    assert(vim.tbl_islist(lines), debug.traceback 'Lines must be an array')

    local indent_level
    for _, line in pairs(lines) do
        if #line > 0 then
            local level = line:match '^%s+'
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

function M.get_indent_block_level(lines)
    vim.validate { lines = { lines, 'table' } }
    assert(vim.tbl_islist(lines), debug.traceback 'Lines must be an array')

    local indent_level = M.get_indent_block(lines)
    return math.floor(indent_level / M.get_indent())
end

function M.get_indent_string(indent)
    vim.validate { indent = { indent, 'number', true } }

    local expand = vim.opt_local.expandtab:get()
    indent = indent or M.get_indent()
    local spaces = not expand and '\t' or string.rep(' ', indent)
    return spaces
end

local function normalize_indent(lines, indent)
    local expand = vim.opt_local.expandtab:get()
    local spaces = M.get_indent_string(indent)

    for i = 1, #lines do
        if #lines[i] > 0 and not lines[i]:match '^%s+$' then
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
    vim.validate { lines = { lines, 'table' }, level = { level, 'number' } }
    assert(vim.tbl_islist(lines), debug.traceback 'Lines must be an array')

    if level == 0 or #lines == 0 then
        return lines
    end

    local abslevel = math.abs(level)

    local indent = M.get_indent()
    local expand = vim.opt_local.expandtab:get()

    lines = normalize_indent(lines, abslevel)

    local spaces = not expand and string.rep('\t', abslevel) or string.rep(' ', indent * abslevel)

    if level < 0 then
        local block_indent = M.get_indent_block(lines)
        if block_indent == 0 then
            return lines
        else
            if not expand then
                block_indent = block_indent * indent
            end

            if block_indent < abslevel * indent then
                return lines
            end
        end
        spaces = '^' .. spaces
    end

    for i = 1, #lines do
        if #lines[i] > 0 and not lines[i]:match '^%s+$' then
            if level < 0 then
                lines[i] = lines[i]:gsub(spaces, '')
            else
                lines[i] = spaces .. lines[i]
            end
        end
    end

    return lines
end

-- TODO: Make this function async, maybe using readfile
-- TODO: Respect indent format from editorconfig and other files
-- TODO: Use treesitter to detect comments and strings
function M.detect_indent(buf)
    vim.validate { buffer = { buf, 'number' } }

    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    local indent = vim.api.nvim_buf_get_option(buf, 'tabstop')
    local expandtab = vim.api.nvim_buf_get_option(buf, 'expandtab')

    local line_idx = 0
    local last_line = vim.fn.line '$'
    -- NOTE: Should we ignore comments ?
    while true do
        local line = vim.api.nvim_buf_get_lines(buf, line_idx, line_idx + 1, true)[1]
        if #line > 0 and not line:match '^%s*$' then
            local indent_str = line:match '^(%s+)[^%s]+'
            if indent_str then
                -- NOTE: we may need to confirm tab indent with more than 1 line
                --       and avoid mix indent
                if indent_str:match '^\t+$' then
                    expandtab = false
                    break
                    -- TODO: this accept indent == 6
                elseif indent_str:match '^ +$' and #indent_str % 2 == 0 and #indent_str < 9 then
                    indent = #indent_str
                    expandtab = true
                    break
                end
            end
        end
        line_idx = line_idx + 1
        if line_idx == last_line then
            break
        end
    end

    vim.api.nvim_buf_set_option(buf, 'expandtab', expandtab)
    if not expandtab then
        vim.api.nvim_buf_set_option(buf, 'softtabstop', -1)
        vim.api.nvim_buf_set_option(buf, 'shiftwidth', 0)
        vim.api.nvim_buf_set_option(buf, 'tabstop', indent)
    end
end

return M
