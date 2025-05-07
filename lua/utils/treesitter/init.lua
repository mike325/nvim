local nvim = require 'nvim'

local M = {}

-- Copied from nvim-treesitter in ts_utils
function M.get_vim_range(range, buf)
    local srow, scol, erow, ecol = unpack(range)
    srow = srow + 1
    scol = scol + 1
    erow = erow + 1

    if ecol == 0 then
        -- Use the value of the last col of the previous row instead.
        erow = erow - 1
        if not buf or buf == 0 then
            ecol = vim.fn.col { erow, '$' } - 1
        else
            ecol = #vim.api.nvim_buf_get_lines(buf, erow - 1, erow, false)[1]
        end
    end
    return { srow, scol, erow, ecol }
end

-- local function is_in_range(linenr, range)
--     if linenr >= range[1] and linenr <= range[2] then
--         return true
--     end
--     return false
-- end

-- luacheck: ignore 631
-- Took from: https://github.com/folke/todo-comments.nvim/blob/9983edc5ef38c7a035c17c85f60ee13dbd75dcc8/lua/todo-comments/highlight.lua#L43,#L71
-- Checks if any TS nodes names are in the given range
-- @param node table: list of nodes to look for
-- @param range table: range to look for the node
-- @param buf number: buffer number
-- @return true or false otherwise
function M.is_in_node(node, range, buf)
    vim.validate {
        node = {
            node,
            function(n)
                return type(n) == type '' or vim.islist(n)
            end,
            'should be a string or an array',
        },
        range = {
            range,
            function(r)
                return r == nil or vim.islist(r)
            end,
            'an array or nil',
        },
        buf = { buf, 'number', true },
    }

    buf = buf or vim.api.nvim_get_current_buf()
    if not pcall(vim.treesitter.get_parser, buf) then
        return false
    end

    if not range then
        range = vim.api.nvim_win_get_cursor(0)
        range[1] = range[1] - 1
    end

    if not vim.islist(node) then
        node = { node }
    end

    -- FIXME: This does not work correctly
    -- if vim.list_contains(node, 'comment') then
    --     local langtree = parser:language_for_range(range)
    --     if langtree and langtree:lang() == 'comment' then
    --         return true
    --     end
    -- end

    local tnode
    if vim.treesitter.get_node then
        tnode = vim.treesitter.get_node { ignore_injections = true, bufnr = buf, pos = range }
    else
        tnode = vim.treesitter.get_node_at_pos(buf, range[1], range[2], {})
    end
    while tnode and tnode:parent() and tnode ~= tnode:parent() do
        if vim.list_contains(node, tnode:type()) then
            return true
        end
        tnode = tnode:parent()
    end

    return false
end

function M.get_list_nodes(root_node, tsquery, get_text, buf)
    vim.validate {
        root_node = { root_node, { 'userdata', 'table' } },
        tsquery = { tsquery, 'string' },
        get_text = { get_text, 'boolean', true },
        buf = { buf, 'number', true },
    }

    buf = buf or vim.api.nvim_get_current_buf()

    local parser = vim.F.npcall(vim.treesitter.get_parser, buf)
    if not parser then
        return {}
    end

    local langtree = parser:language_for_range { root_node:range() }
    local ts_lang = langtree:lang()

    local nodes = {}
    local query = vim.treesitter.query.parse(ts_lang, tsquery)

    local function insert_node(node)
        local lbegin, _, lend, _ = unpack(M.get_vim_range({ node:range() }, buf))
        if get_text then
            local node_text = vim.treesitter.get_node_text(node, buf)
            table.insert(nodes, { node_text, lbegin, lend })
        else
            table.insert(nodes, node)
        end
    end

    local function iter_nodes(match_nodes)
        for _, node in pairs(match_nodes) do
            insert_node(node)
        end
    end

    local insert_nodes = nvim.has { 0, 11 } and iter_nodes or insert_node
    for _, match, _ in query:iter_matches(root_node, buf) do
        for _, match_nodes in pairs(match) do
            insert_nodes(match_nodes)
        end
    end

    return nodes
end

function M.list_buf_nodes(tsquery, buf)
    vim.validate {
        tsquery = { tsquery, 'string' },
        buf = { buf, 'number', true },
    }

    buf = buf or vim.api.nvim_get_current_buf()

    local parser = vim.F.npcall(vim.treesitter.get_parser, buf)
    if not parser then
        return {}
    end

    local buf_lines = nvim.buf.line_count(buf)
    local line = nvim.buf.get_lines(buf, buf_lines - 1, buf_lines, false)[1]

    local langtree = parser:language_for_range { 0, 0, buf_lines, #line }

    local results = {}
    for _, tree in pairs(langtree:trees()) do
        local root = tree:root()
        if root then
            results = vim.list_extend(results, M.get_list_nodes(root, tsquery, true, buf))
        end
    end

    return results
end

function M.get_current_node(node_name, range)
    vim.validate {
        node_name = { node_name, 'table' },
    }

    if not M.has_ts() then
        return nil
    end

    if not range then
        range = vim.api.nvim_win_get_cursor(0)
        range[1] = range[1] - 1
    end

    local node
    if vim.treesitter.get_node then
        node = vim.treesitter.get_node()
    else
        node = vim.treesitter.get_node_at_pos(nvim.get_current_buf(), range[1], range[2], {})
    end

    while node do
        if node_name[node:type()] then
            return node
        end
        node = node:parent()
    end
    return nil
end

function M.get_current_func()
    return M.get_current_node {
        function_definition = true,
        function_declaration = true,
        method_definition = true,
        method_declaration = true,
    }
end

function M.get_current_class()
    return M.get_current_node {
        class_definition = true,
        struct_specifier = true,
        class_specifier = true,
    }
end

function M.is_in_function()
    local func = M.get_current_func()
    if func then
        return true
    end
    return false
end

function M.is_in_class()
    local class = M.get_current_class()
    if class then
        return true
    end
    return false
end

function M.has_ts(buf)
    vim.validate { buf = { buf, 'number', true } }
    buf = buf or vim.api.nvim_get_current_buf()
    return (pcall(vim.treesitter.get_parser, buf))
end

return M
