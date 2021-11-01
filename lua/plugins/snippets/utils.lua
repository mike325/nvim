local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

-- local ts_locals = require "nvim-treesitter.locals"
-- local ts_utils = require "nvim-treesitter.ts_utils"

-- local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
-- local isn = ls.indent_snippet_node
local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
-- local d = ls.dynamic_node
-- local l = require("luasnip.extras").lambda
-- local r = require("luasnip.extras").rep
-- local p = require('luasnip.extras').partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
-- local dl = require("luasnip.extras").dynamic_lambda
-- local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local types = require("luasnip.util.types")
-- local events = require("luasnip.util.events")
-- local conds = require("luasnip.extras.expand_conditions")

local M = {}

-- TODO: Update this with TS support
function M.get_comment(text)
    vim.validate { text = { text, 'string', true } }
    local comment = vim.opt_local.commentstring:get()
    if not comment:match '%s%%s' then
        comment = comment:format ' %s'
    end
    return text and comment:format(text) or comment
end

function M.saved_text(args, snip, old_state, placeholder)
    local nodes = {}
    if not old_state then
        old_state = {}
    end
    if not placeholder then
        placeholder = {}
    end
    local indent = placeholder.indent and '\t' or ''

    if snip.env and snip.env.SELECT_RAW and #snip.env.SELECT_RAW > 0 then
        local lines = vim.deepcopy(snip.env.SELECT_RAW)
        if #indent ~= 0 then
            for idx = 1, #lines do
                lines[idx] = indent .. lines[idx]
            end
        end
        for idx = 1, #lines do
            local node = idx == #lines and { lines[idx] } or { lines[idx], '' }
            table.insert(nodes, t(node))
        end
    else
        local text = placeholder.text or M.get_comment():format 'code'
        if #indent ~= 0 then
            table.insert(nodes, t(indent))
        end
        table.insert(nodes, i(1, text))
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

function M.surround_with_func(args, snip, old_state, placeholder)
    local nodes = {}
    if not old_state then
        old_state = {}
    end
    if not placeholder then
        placeholder = {}
    end

    if snip.env and snip.env.SELECT_RAW and #snip.env.SELECT_RAW == 1 then
        local node = snip.env.SELECT_RAW[1]
        table.insert(nodes, t(node))
    else
        local text = placeholder.text or 'placeholder'
        table.insert(nodes, i(1, text))
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

function M.copy(args)
    return args[1]
end

return M
