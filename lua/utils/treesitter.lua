local M = {}

-- luacheck: ignore 631
-- Took from: https://github.com/folke/todo-comments.nvim/blob/9983edc5ef38c7a035c17c85f60ee13dbd75dcc8/lua/todo-comments/highlight.lua#L43,#L71
-- Checks if the 3 TS nodes nodes in a range correspond with the target node
-- @param range table: range to look for the node
-- @param node table: list of nodes to look for
-- @param buf number: buffer number
-- @return true or false otherwise
function M.is_node(range, node, buf)
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

    local ok, parser = pcall(vim.treesitter.get_parser, buf)
    if not ok then
        return
    end

    local langtree = parser:language_for_range(range)
    local query = vim.treesitter.get_query(langtree:lang(), 'highlights')

    local found_node = false
    -- TODO: This has poor perfmance (at least on windows), need to find a way to improve it
    langtree:for_each_tree(function(tree, lang_tree)
        if found_node then
            return
        end

        local i = 0

        -- _ is id and metadata is not necesary
        for _, tsnode in query:iter_captures(tree:root(), buf, range[1], range[1] + 1) do
            -- local name = query.captures[id]
            local ntype = tsnode:type()
            if vim.tbl_contains(node, ntype) then
                found_node = true
                break
            end
            i = i + 1
            if i == 4 then
                break
            end
        end
    end)
    return found_node
end

return M
