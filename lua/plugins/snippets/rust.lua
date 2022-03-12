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
local fmt = require('luasnip.extras.fmt').fmt
-- local fmta = require('luasnip.extras.fmt').fmta
-- local types = require 'luasnip.util.types'
-- local events = require 'luasnip.util.events'
-- local conds = require 'luasnip.extras.expand_conditions'

local utils = RELOAD 'plugins.snippets.utils'
local saved_text = utils.saved_text
local get_comment = utils.get_comment
-- local surround_with_func = utils.surround_with_func

local function else_clause(args, snip, old_state, placeholder)
    local nodes = {}

    if snip.captures[1] == 'e' then
        table.insert(nodes, t { ' else {', '\t' })
        table.insert(nodes, i(1, get_comment 'code'))
        table.insert(nodes, t { '', '}' })
    else
        table.insert(nodes, t { '' })
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

-- TODO: Add pcall snippet and use TS to parse saved function and separete the funcion name and the args
-- stylua: ignore
ls.snippets.rust = {
    s('for', fmt([[
    for {} in {} {{
    {}
    }}
    ]], {
        i(1, 'key'),
        i(2, 'iterator'),
        d(3, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s(
        { trig = 'if(e?)', regTrig = true },
        fmt([[
    if {} {{
    {}
    }}{}
    ]], {
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
        d(3, else_clause, {}, {}),
    })),
    -- s('elif', fmt([[
    -- else if {} {{
    -- {}
    -- }}
    -- ]],{
    --     i(1, 'condition'),
    --     d(2, saved_text, {}, {user_args = {{indent = true}}}),
    -- })),
    s('w', fmt([[
    while {} {{
    {}
    }}
    ]], {
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
    })),
    s('pr', fmt([[println!({});]],{
        i(1, 'msg'),
    })),
    s('let', fmt([[let {} = {};]],{
        i(1, 'name'),
        i(2, '0'),
    })),
    s('mut', fmt([[let mut {} = {};]],{
        i(1, 'name'),
        i(2, '0'),
    })),
    s(
        { trig = 'f(u?)n', regTrig = true },
        fmt([[
            fn {}({}) {{
            {}
            }}
        ]],
        {
            i(1, 'name'),
            i(2, 'args'),
            d(3, saved_text, {}, {user_args = {{indent = true}}}),
        }
    )),
}
