local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
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

-- stylua: ignore
return {
    s(
        { trig = 'if(e?)', regTrig = true },
        fmt([=[
        if [[ {} ]]; then
        {}
        {}fi
        ]=], {
            i(1, 'condition'),
            d(2, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
            d(3, else_clause, {}, {}),
        })
    ),
    s('elseif', fmt([=[
    elif [[ {} ]]; then
    {}
    ]=],{
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
    })),
    s('elif', fmt([=[
    elif [[ {} ]]; then
    {}
    ]=],{
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
    })),
    s('fun', fmt([[
    function {}() {{
    {}
    }}
    ]], {
        i(1, 'name'),
        d(2, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
    })),
    s('for', fmt([[
    for {} in {}; do
    {}
    done
    ]], {
        i(1, 'i'),
        i(2, 'Iterator'),
        d(3, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
    })),
    s('fori', fmt([[
    for (({} = {}; {} < {}; {}++)); do
    {}
    done
    ]], {
        i(1, 'i'),
        i(2, '0'),
        r(1),
        i(3, '10'),
        r(1),
        d(4, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
    })),
    s('wh', fmt([=[
    while [[ {} ]]; do
    {}
    done
    ]=], {
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{text = ':', indent = true}}}),
    })),
    s('l', fmt([[local {}={}]],{
        i(1, 'varname'),
        i(2, '1'),
    })),
    s('ex', fmt([[export {}={}]],{
        i(1, 'varname'),
        i(2, '1'),
    })),
    s('ha', fmt([[hash {} 2>/dev/null ]],{
        i(1, 'cmd'),
    })),
    s('case', fmt([[
    case ${} in
        {})
            {}
            ;;
    esac
    ]],{
        i(1, 'VAR'),
        i(2, 'CONDITION'),
        i(3, ':'),
    })),
}
