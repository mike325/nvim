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

function M.bufloaded(buffer)
    vim.validate {
        buffer = {
            buffer,
            function(b)
                return type(b) == type '' or type(b) == type(1)
            end,
            'filepath string or a buffer number',
        },
    }
    -- return vim.api.nvim_buf_is_loaded(bufnr)
    return vim.fn.bufloaded(buffer) == 1
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
    local tmp_lines = vim.deepcopy(lines)

    tmp_lines = normalize_indent(tmp_lines, abslevel)

    local spaces = not expand and string.rep('\t', abslevel) or string.rep(' ', indent * abslevel)

    if level < 0 then
        local block_indent = M.get_indent_block(tmp_lines)
        if block_indent == 0 then
            return tmp_lines
        else
            if not expand then
                block_indent = block_indent * indent
            end

            if block_indent < abslevel * indent then
                return tmp_lines
            end
        end
        spaces = '^' .. spaces
    end

    for i = 1, #tmp_lines do
        if #tmp_lines[i] > 0 and not tmp_lines[i]:match '^%s+$' then
            if level < 0 then
                tmp_lines[i] = tmp_lines[i]:gsub(spaces, '')
            else
                tmp_lines[i] = spaces .. tmp_lines[i]
            end
        end
    end

    return tmp_lines
end

-- luacheck: ignore 631
-- Took from: https://github.com/folke/todo-comments.nvim/blob/9983edc5ef38c7a035c17c85f60ee13dbd75dcc8/lua/todo-comments/highlight.lua#L43,#L71
-- This method returns nil if this buf doesn't have a treesitter parser
-- @return true or false otherwise
function M.is_node(line, node, buf)
    vim.validate {
        buf = { buf, 'number', true },
        line = { line, 'number' },
        node = {
            node,
            function(n)
                return not n or type(n) == type '' or vim.tbl_islist(n)
            end,
            'should be a string or an array',
        },
    }
    buf = buf or vim.api.nvim_get_current_buf()
    node = node or { 'comment' }

    if not vim.tbl_islist(node) then
        node = { node }
    end

    local highlighter = require 'vim.treesitter.highlighter'
    local hl = highlighter.active[buf]

    if not hl then
        return
    end

    local found_node = false
    hl.tree:for_each_tree(function(tree, lang_tree)
        if found_node then
            return
        end

        local query = hl:get_query(lang_tree:lang())
        if not (query and query:query()) then
            return
        end

        local iter = query:query():iter_captures(tree:root(), buf, line, line + 1)

        for capture, _ in iter do
            if vim.tbl_contains(node, query._query.captures[capture]) then
                found_node = true
            end
        end
    end)
    return found_node
end

-- TODO: Make this function async, maybe using readfile
-- TODO: Respect indent format from editorconfig and other files
-- TODO: Cache indent settings using SQLite?
function M.detect_indent(buf)
    vim.validate { buffer = { buf, 'number', true } }

    buf = buf or vim.api.nvim_get_current_buf()

    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    local ignore_fts = {
        man = true,
        help = true,
        qf = true,
        Telescope = true,
        TelescopePrompt = true,
        TelescopeResults = true,
    }

    local ft = vim.api.nvim_buf_get_option(buf, 'filetype')
    local ok, indent_set = pcall(vim.api.nvim_buf_get_var, buf, 'indent_set')
    indent_set = ok and indent_set or false

    if ignore_fts[ft] or indent_set then
        return
    end

    local indent = vim.api.nvim_buf_get_option(buf, 'tabstop')
    local expandtab = vim.api.nvim_buf_get_option(buf, 'expandtab')

    -- NOTE: JSON/Yaml can be detected as mostly string nodes, so we bypass this that check
    local bypass_ft = {
        json = true,
        yaml = true,
    }

    local line_idx = 0
    -- BUG: This hangs neovim's startup, seems to be a race condition, tested in windows 10
    -- local last_line = vim.api.nvim_buf_line_count(buf)
    local last_line = vim.fn.line '$'
    while true do
        local line = vim.api.nvim_buf_get_lines(buf, line_idx, line_idx + 1, true)[1]
        if line and #line > 0 and not line:match '^%s*$' then
            -- Use TS to avoid multiline strings and comments
            if
                bypass_ft[ft] or (not M.is_node(line_idx, 'string') and not M.is_node(line_idx, 'comment'))
            then
                local indent_str = line:match '^(%s+)[^%s]+'
                if indent_str then
                    -- NOTE: we may need to confirm tab indent with more than 1 line and avoid mix indent
                    if indent_str:match '^\t+$' then
                        expandtab = false
                        break
                        -- TODO: this accepts indent == 6
                    elseif indent_str:match '^ +$' and #indent_str % 2 == 0 and #indent_str < 9 then
                        -- vim.notify('Setting stuff using indent in line for not TS: '..line_idx)
                        indent = #indent_str
                        expandtab = true
                        break
                    end
                end
            end
        end
        line_idx = line_idx + 1
        if line_idx == last_line then
            break
        end
    end

    vim.api.nvim_buf_set_option(buf, 'expandtab', expandtab)
    vim.api.nvim_buf_set_option(buf, 'tabstop', indent)
    vim.api.nvim_buf_set_option(buf, 'softtabstop', -1)
    vim.api.nvim_buf_set_option(buf, 'shiftwidth', 0)

    -- Cache this indent to avoid re-set it
    vim.api.nvim_buf_set_var(buf, 'indent_set', true)

    return indent
end

return M
