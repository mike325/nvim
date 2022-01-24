local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local s = ls.snippet
local sn = ls.snippet_node
local t = ls.text_node
-- local isn = ls.indent_snippet_node
local i = ls.insert_node
-- local f = ls.function_node
-- local c = ls.choice_node
local d = ls.dynamic_node
-- local l = require('luasnip.extras').lambda
-- local r = require('luasnip.extras').rep
-- local p = require('luasnip.extras').partial
-- local m = require('luasnip.extras').match
-- local n = require('luasnip.extras').nonempty
-- local dl = require('luasnip.extras').dynamic_lambda
-- local fmt = require('luasnip.extras.fmt').fmt
-- local fmta = require('luasnip.extras.fmt').fmta
-- local types = require 'luasnip.util.types'
-- local events = require 'luasnip.util.events'
-- local conds = require 'luasnip.extras.expand_conditions'

local utils = RELOAD 'plugins.snippets.utils'
local saved_text = utils.saved_text
-- local get_comment = utils.get_comment
-- local surround_with_func = utils.surround_with_func

local function else_clause(args, snip, old_state, placeholder)
    local nodes = {}

    if snip.captures[1] == 'e' then
        table.insert(nodes, t { '', 'else', '\t' })
        table.insert(nodes, i(1, ':'))
    else
        table.insert(nodes, t { '' })
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

-- stylua: ignore
ls.snippets.sh = {
    s(
        { trig = "if(e?)", regTrig = true },
        {
            t{"if [[ "}, i(1, 'condition'), t{" ]]; then", ""},
                d(2, saved_text, {}, {text = ':', indent = true}),
            d(3, else_clause, {}, {}),
            t{"", "fi"},
        }
    ),
    s("fun", {
        t{"function "}, i(1, 'name'), t{"() {", ""},
            d(2, saved_text, {}, {text = ':', indent = true}),
        t{"", "}"},
    }),
    s("for", {
        t{"for "}, i(1, 'i'), t{" in "}, i(2, 'Iterator'), t{"; do", ""},
            d(3, saved_text, {}, {text = ':', indent = true}),
        t{"", "done"}
    }),
    s("wh", {
        t{"while "}, i(1, '[[ condition ]]'), t{"; do"},
            d(2, saved_text, {}, {text = ':', indent = true}),
        t{"", "done"}
    }),
    s("case", {
        t{'case "'}, i(1, '$VAR'), t{'" in', ""},
            t{"\t"}, i(2, 'condition'), t{" )", ""},
                t{"\t\t"}, i(3, ':'),
            t{"", "\t\t;;"},
        t{"", "esac"}
    }),
}
