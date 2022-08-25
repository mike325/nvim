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
-- local surround_with_func = utils.surround_with_func

-- TODO: Add pcall snippet and use TS to parse saved function and separete the funcion name and the args
-- stylua: ignore
return {
    s('for', fmt([[
    for {}, {} := range {} {{
    {}
    }}
    ]], {
        i(1, 'key'),
        i(2, 'val'),
        i(3, 'iterator'),
        d(4, saved_text, {}, {user_args = {{indent = true}}}),
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
        d(4, saved_text, {}, {user_args = {{indent = true}}}),
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
            d(2, saved_text, {}, {user_args = {{indent = true}}}),
            d(3, else_clause, {}, {}),
        }
    )),
    s('elif', fmt([[
    else if {} {{
    {}
    }}
    ]],{
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s('w', fmt([[
    for {} {{
    {}
    }}
    ]], {
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
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
        func {}({}) {}{{
        {}
        }}
        ]],{
            i(1, 'name'),
            i(2, 'args'),
            c(3, {
                sn(nil, fmt('({}, error)', {i(1, 'string')})),
                sn(nil, fmt('{}', {i(1, 'string')})),
                t{''},
            }),
            d(4, saved_text, {}, {user_args = {{indent = true}}}),
        }
    )),
    s('ef', fmt([[
            {}, {} := {}({})
        ]],
        {
            i(1, 'val'),
            i(2, 'err'),
            i(3, 'func'),
            i(4, 'args'),
        }
    )),
    s('mk', fmt([[
            make({}, {})
        ]],
        {
            i(1, '[]string'),
            i(2, '10'),
        }
    )),
    s('map', fmt([[
            map [{}]{} {{}}
        ]],
        {
            i(1, 'string'),
            i(2, 'int'),
        }
    )),
    s('str', fmt([[
        type {} struct {{
            {}  {}
        }}
        ]],
        {
            i(1, 'name'),
            i(2, 'attr'),
            i(3, 'int'),
        }
    )),
    s('tfun', fmt([[
        func Test{}(t *testing.T) {{
            t.Run("{}", func(t *testing.T) {{
            {}
            }})
        }}
        ]],
        {
            i(1, 'name'),
            i(2, 'desciption'),
            d(3, saved_text, {}, {user_args = {{indent = true}}}),
        }
    )),
    s('trun', fmt([[
        t.Run("{}", func(t *testing.T) {{
        {}
        }})
        ]],
        {
            i(1, 'desciption'),
            d(2, saved_text, {}, {user_args = {{indent = true}}}),
        }
    )),
    s('met', fmt([[
        func (self *{}) {}({}) {}{{
        {}
        }}
        ]], {
            i(1, 'Obj'),
            i(2, 'method'),
            i(3, 'args'),
            c(4, {
                sn(nil, fmt('({}, error)', {i(1, 'string')})),
                sn(nil, fmt('{}', {i(1, 'string')})),
                t{''},
            }),
            d(5, saved_text, {}, {user_args = {{indent = true}}}),
        }
    )),
    s('case', fmt([[
        case {}:
        {}
        ]], {
            i(1, 'match'),
            d(2, saved_text, {}, {user_args = {{indent = true}}}),
        }
    )),
    s('sw', fmt([[
        switch {}{{
        case {}:
        {}
        default:
            {}
        }}
        ]], {
            c(1, {
                sn(nil, fmt('{} ', {i(1, 'var')})),
                t{''},
            }),
            i(2, 'match'),
            d(3, saved_text, {}, {user_args = {{indent = true}}}),
            i(4, 'break'),
        }
    )),
}
