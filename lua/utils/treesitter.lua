local nvim = require 'neovim'

local M = {}

local queries = {
    ['function'] = {
        lua = [[
            (function_declaration)
            [
                (function_declaration name: [
                    ((identifier) @function) ((dot_index_expression field: (identifier) @function))
                ])
            ] @function_name
        ]],
        python = [[
            (function_definition)
            [
                (function_definition name: (identifier) @definition.function)
            ] @function_name
        ]],
        go = [[
            [
                (function_declaration)
                (method_declaration)
            ] @func

            [
                (function_declaration name: (identifier) @definition.function)
                (method_declaration name: (field_identifier) @definition.method)
            ] @function_name
        ]],
    },
    class = {
        cpp = [[
            [
                (struct_specifier)
                (class_specifier)
            ] @class

            [
                (struct_specifier name: [((type_identifier) @name) (template_type name: (type_identifier) @name)])
                (class_specifier name: [((type_identifier) @name) (template_type name: (type_identifier) @name)])
            ] @class_name
        ]],
        python = [[
            (class_definition)
            [
                (class_definition name: (identifier) @definition.type)
            ] @class_name
        ]],
    },
}

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

local function is_in_range(linenr, range)
    if linenr >= range[1] and linenr <= range[2] then
        return true
    end
    return false
end

function M.get_node_at_range(range, buf)
    vim.validate {
        range = { range, 'table' },
        buf = { buf, 'number', true },
    }
    buf = buf or vim.api.nvim_get_current_buf()
    local ok, parser = pcall(vim.treesitter.get_parser, buf)
    if not ok then
        return nil
    end

    local langtree = parser:language_for_range(range)
    -- local ts_lang = langtree:lang()

    for _, tree in ipairs(langtree:trees()) do
        local root = tree:root()
        if root then
            local tsnode = root:named_descendant_for_range(unpack(range))
            if tsnode then
                return tsnode
            end
        end
    end

    return nil
end

function M.get_node_at_cursor()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local range = { cursor[1] - 1, cursor[2], cursor[1] - 1, cursor[2] }
    return M.get_node_at_range(range, vim.api.nvim_get_current_buf())
end

-- luacheck: ignore 631
-- Took from: https://github.com/folke/todo-comments.nvim/blob/9983edc5ef38c7a035c17c85f60ee13dbd75dcc8/lua/todo-comments/highlight.lua#L43,#L71
-- Checks if any TS nodes names are in the given range
-- @param range table: range to look for the node
-- @param node table: list of nodes to look for
-- @param buf number: buffer number
-- @return true or false otherwise
function M.is_in_node(range, node, buf)
    vim.validate {
        buf = { buf, 'number', true },
        range = {
            range,
            function(r)
                return vim.tbl_islist(r)
            end,
            'an array',
        },
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

    local tnode = M.get_node_at_range(range, buf)
    while tnode and tnode:parent() and tnode ~= tnode:parent() do
        if vim.tbl_contains(node, tnode:type()) then
            return true
        end
        tnode = tnode:parent()
    end

    return false
end

function M.list_nodes(node_type)
    local buf = vim.api.nvim_get_current_buf()

    local ok, parser = pcall(vim.treesitter.get_parser, buf)
    if not ok then
        return {}
    end

    local buf_lines = nvim.buf.line_count(0)
    local line = nvim.buf.get_lines(0, buf_lines - 1, buf_lines, false)[1]

    local langtree = parser:language_for_range { 0, 0, buf_lines, #line }
    local ts_lang = langtree:lang()

    if not queries[node_type] or not queries[node_type][ts_lang] then
        return {}
    end

    local result = {}
    for _, tree in ipairs(langtree:trees()) do
        local root = tree:root()

        if root then
            local query = vim.treesitter.parse_query(ts_lang, queries[node_type][ts_lang])
            for _, node, _ in query:iter_matches(root, buf) do
                if #node > 1 then
                    local func_name, func_range
                    for _, v in pairs(node) do
                        if not func_name then
                            func_name = v
                        else
                            func_range = v
                            break
                        end
                    end
                    local lbegin, _, lend, _ = unpack(M.get_vim_range { func_range:range() })
                    local name = vim.treesitter.query.get_node_text(func_name, buf)
                    table.insert(result, { name, lbegin, lend })
                end
            end
        end
    end

    return result
end

function M.get_current_node(node_name, linenr)
    vim.validate {
        node_name = { node_name, 'string' },
        linenr = { linenr, 'number', true },
    }
    linenr = linenr or nvim.win.get_cursor(0)[1]

    local func_list = M.list_nodes(node_name)

    for idx, func in ipairs(func_list) do
        if is_in_range(linenr, { func[2], func[3] }) then
            return func_list[idx]
        end
    end

    return nil
end

function M.get_current_func(linenr)
    return M.get_current_node('function', linenr)
end

function M.get_current_class(linenr)
    return M.get_current_node('class', linenr)
end

-- TODO: Make sure we only iterate over the current language/filetype tree
--       since comments, docstrings and other components may be embedded, this causes that
--       comments inside functions are reported as false
function M.is_in_function()
    local current_node = M.get_node_at_cursor()
    if not current_node then
        return false
    end
    local node = current_node

    local func_nodes = {
        function_definition = true,
        function_declaration = true,
        method_definition = true,
        method_declaration = true,
    }

    while node do
        if func_nodes[node:type()] then
            return true
        end
        node = node:parent()
    end
    return false
end

function M.has_ts(buf)
    vim.validate { buf = { buf, 'number', true } }
    buf = buf or vim.api.nvim_get_current_buf()
    local ok, _ = pcall(vim.treesitter.get_parser, buf)
    return ok
end

return M
