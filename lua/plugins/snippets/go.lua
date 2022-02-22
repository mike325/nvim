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
local c = ls.choice_node
local d = ls.dynamic_node
-- local l = require('luasnip.extras').lambda
local r = require('luasnip.extras').rep
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
ls.snippets.go = {
    s('for', fmt([[
    for {}, {} := range {} {{
    {}
    }}
    ]], {
        i(1, 'key'),
        i(2, 'val'),
        i(3, 'iterator'),
        d(4, saved_text, {}, {indent = true}),
    })),
    s('fori', fmt([[
    for {} = {}; {} < {}; {}++ {{
    {}
    }}
    ]], {
        i(1, 'i'),
        i(2, '0'),
        r(1),
        i(3, '10'),
        r(1),
        d(4, saved_text, {}, {text = ':', indent = true}),
    })),
    s(
        { trig = 'if(e?)', regTrig = true },
        fmt([[
            if {} {{
            {}
            }}{}
        ]],
        {
            i(1, 'condition'),
            d(2, saved_text, {}, {indent = true}),
            d(3, else_clause, {}, {}),
        }
    )),
    s('elif', fmt([[
    else if {} {{
    {}
    }}
    ]],{
        i(1, 'condition'),
        d(2, saved_text, {}, {indent = true}),
    })),
    s('w', fmt([[
    for {} {{
    {}
    }}
    ]], {
        i(1, 'condition'),
        d(2, saved_text, {}, {text = ':', indent = true}),
    })),
    s('pr', fmt([[fmt.Println({})]],{
        i(1, 'msg'),
    })),
    s('var', fmt([[var {} {}]],{
        i(1, 'name'),
        c(2, {
            i(1, 'int'),
            i(1, 'string'),
        }),
    })),
    s(
        { trig = 'fun(c?)', regTrig = true },
        fmt([[
    func {}({}){{
    {}
    }}
    ]],{
        i(1, 'name'),
        i(2, 'args'),
        d(3, saved_text, {}, {indent = true}),
    })),
    s(
        { trig = 'ef', regTrig = true },
        fmt([[
            {}, {} := {}({})
        ]],
        {
            i(1, 'val'),
            i(2, 'err'),
            i(3, 'func'),
            i(4, 'args'),
        }
    )),
}
