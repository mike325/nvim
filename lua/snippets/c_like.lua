local load_module = require('utils.functions').load_module
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

local utils = RELOAD 'plugins.luasnip.utils'
local saved_text = utils.saved_text
local else_clause = utils.else_clause
-- local return_value = utils.return_value
-- local surround_with_func = utils.surround_with_func

local function rec_args()
    return sn(nil, {
        c(1, {
            t { '' },
            sn(nil, {
                t { ', ' },
                c(1, {
                    i(1, 'int'),
                    i(1, 'char*'),
                    i(1, 'float'),
                    i(1, 'long'),
                }),
                t { ' ' },
                i(2, 'varname'),
                d(3, rec_args, {}),
            }),
        }),
    })
end

-- stylua: ignore
local snippets = {
    s(
        { trig = 'if(e?)', regTrig = true },
        fmt([[
    if({}) {{
    {}
    }}{}
    ]], {
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
        d(3, else_clause, {}, {}),
    })),
    s('elif', fmt([[
    else if({}) {{
    {}
    }}
    ]],{
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s('fori', fmt([[
    for({} = {}; {} < {}; {}++) {{
    {}
    }}
    ]], {
        i(1, 'i'),
        i(2, '0'),
        r(1),
        i(3, '10'),
        r(1),
        d(4, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s('w', fmt([[
    while({}) {{
    {}
    }}
    ]], {
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s('fun', fmt([[
    {} {}({}{}) {{
    {}
    }}
    ]], {
        c(1, {
            i(1, 'int'),
            i(1, 'char*'),
            i(1, 'float'),
            i(1, 'long'),
        }),
        i(2, 'name'),
        c(3, {
            t{''},
            sn(nil, {
                c(1, {
                    i(1, 'int'),
                    i(1, 'char*'),
                    i(1, 'float'),
                    i(1, 'long'),
                }),
                t{' '},
                i(2, 'varname'),
            }),
        }),
        d(4, rec_args, {}),
        d(5, saved_text, {}, {user_args = {{indent = true}}}),
    })),
}

return snippets
