local ls = vim.F.npcall(require, 'luasnip')
if not ls then
    return false
end

local s = ls.snippet
-- local sn = ls.snippet_node
-- local t = ls.text_node
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

local utils = RELOAD 'configs.luasnip.utils'
local saved_text = utils.saved_text
local else_clause = utils.else_clause
-- local surround_with_func = utils.surround_with_func

-- stylua: ignore
return {
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
    elseif({}) {{
    {}
    }}
    ]],{
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s('env', fmt([[$env:{}]],{ i(1, 'VAR'), })),
    s('for', fmt([[
    foreach({} in {}) {{
    {}
    }}
    ]],{
        i(1, 'i'),
        i(2, 'range'),
        d(3, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s('tp', fmt([[
    Test-Path "{}"
    ]],{
        i(1, 'PATH'),
    })),
    s('fun', fmt([[
    function {} {{
    {}
    }}
    ]],{
        i(1, 'name'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
    })),
}
