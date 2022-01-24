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

    local ts_to_ft = {
        bash = 'sh',
    }

    local langtree = parser:language_for_range(range)
    -- local buf_lang = vim.api.nvim_buf_get_option(buf, 'filetype')
    local ts_lang = langtree:lang()
    ts_lang = ts_to_ft[ts_lang] or ts_lang

    local found_node = false
    local root = langtree:trees()[1]:root()
    local tnode = root:named_descendant_for_range(unpack(range))
    -- NOTE: langtree can be "comment" so we do a safe check to avoid "comment" treesitter language
    if vim.tbl_contains(node, ts_lang) or vim.tbl_contains(node, tnode:type()) then
        found_node = true
    end

    return found_node
end

function M.has_ts(buf)
    vim.validate { buf = { buf, 'number', true } }
    buf = buf or vim.api.nvim_get_current_buf()
    local ok, _ = pcall(vim.treesitter.get_parser, buf)
    return ok
end

return M
