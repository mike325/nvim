local ls = vim.F.npcall(require, 'luasnip')
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
local p = require('luasnip.extras').partial
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

local function python_class_init(args, snip, old_state, placeholder)
    local nodes = {}

    if snip.captures[1] == 'd' then
        table.insert(
            nodes,
            c(1, {
                t { '' },
                sn(nil, { t { '\t' }, i(1, 'attr') }),
            })
        )
    else
        table.insert(nodes, t { '', '\tdef __init__(self' })
        table.insert(
            nodes,
            c(1, {
                t { '' },
                sn(nil, { t { ', ' }, i(1, 'arg') }),
            })
        )
        table.insert(nodes, t { '):', '\t\t' })
        table.insert(nodes, i(2, 'pass'))
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

local function python_dataclass(args, snip, old_state, placeholder)
    local nodes = {}

    table.insert(nodes, snip.captures[1] == 'd' and t { '@dataclass', '' } or t { '' })

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

local function async_def(args, snip, old_state, placeholder)
    local nodes = {}

    table.insert(nodes, snip.captures[1] == 'a' and t { 'async def' } or t { 'def' })

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

-- stylua: ignore
return {
    s('for', fmt([[
    for {} in {}:
    {}
    ]], {
        i(1, 'i'),
        i(2, 'iterator'),
        d(3, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
    })),
    s('pr', fmt([[print({})]],{
        i(1, 'msg'),
    })),
    s('ran', fmt([[range({}, {})]],{
        i(1, '0'),
        i(2, '10'),
    })),
    s('imp', fmt([[import {}]],{
        i(1, 'sys'),
    })),
    s(
        { trig = 'fro(m?)', regTrig = true },
        fmt([[from {} import {}]],
        {
            i(1, 'sys'),
            i(2, 'path'),
        }
    )),
    s(
        { trig = 'if(e?)', regTrig = true },
        fmt([[
    if {}:
    {}{}
    ]], {
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
        d(3, else_clause, {}, {}),
    })),
    s(
        {trig = '(a?)def', regTrig = true},
        fmt([[
    {} {}({}{}):
    {}
    ]], {
        d(1, async_def, {}, {user_args = {}}),
        i(2, 'name'),
        p(function()
            -- stylua: ignore
            local get_current_class = require('utils.treesitter').get_current_class
            -- stylua: ignore
            local has_ts = require('utils.treesitter').has_ts()
            -- stylua: ignore
            if has_ts and get_current_class() then
                -- stylua: ignore
                return 'self, '
            end
            -- stylua: ignore
            return ''
        end),
        i(3, 'args'),
        d(4, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
    })),
    s('try', fmt([[
    try:
    {}
    except {}:
        {}
    ]], {
        d(1, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
        c(2, {
            t{'Exception as e'},
            t{'KeyboardInterrupt as e'},
            sn(nil, { i(1, 'Exception') }),
        }),
        i(3, 'pass'),
    })),
    s('ifmain', fmt([[
    if __name__ == "__main__":
        {}
    else:
        {}
    ]], {
        c(1, {
            sn(nil, { t{'exit('}, i(1, 'main()'), t{')'} }),
            t{'pass'},
        }),
        i(2, 'pass'),
    })),
    s('with', fmt([[
    with open('{}', {}) as {}:
    {}
    ]], {
        i(1, 'filename'),
        c(2, {
            i(1, '"r"'),
            i(1, '"a"'),
            i(1, '"w"'),
        }),
        i(3, 'data'),
        d(4, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
    })),
    s('w', fmt([[
    while {}:
    {}
    ]], {
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{text = 'pass', indent = true}}}),
    })),
    s(
        { trig = "(d?)cl", regTrig = true },
        fmt([[
        {}class {}({}):
            {}
        ]],
        {
            d(1, python_dataclass, {}, {}),
            i(2, 'Class'),
            c(3, {
                t{''},
                i(1, 'object'),
            }),
            -- dl(4, l._1 .. ': docstring', { 2 }),
            d(4, python_class_init, {}, {}),
        }
    )),
    s('raise', fmt([[raise {}({})]],{
        c(1, {
            i(1, 'Exception'),
            i(1, 'KeyboardInterrupt'),
            i(1, 'IOException'),
        }),
        i(2, 'message'),
    })),
    s('clist', fmt('[{} for {} in {}{}]',{
        r(1),
        i(1, 'i'),
        i(2, 'Iterator'),
        c(3, {
            t{''},
            sn(nil, {t' if ', i(1, 'condition') }),
        }),
    })),
    s('cdict', fmt('{{ {}:{} for ({},{}) in {}{}}}',{
        r(1),
        r(2),
        i(1, 'k'),
        i(2, 'v'),
        i(3, 'Iterator'),
        c(4, {
            t{''},
            sn(nil, {t' if ', i(1, 'condition') }),
        }),
    })),
}
