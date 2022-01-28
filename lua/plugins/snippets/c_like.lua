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
local get_comment = utils.get_comment
-- local return_value = utils.return_value
-- local surround_with_func = utils.surround_with_func

local function else_clause(args, snip, old_state, placeholder)
    local nodes = {}

    if snip.captures[1] == 'e' then
        table.insert(nodes, t { '', 'else {', '\t' })
        table.insert(nodes, i(1, get_comment 'code'))
        table.insert(nodes, t { '', '}' })
    else
        table.insert(nodes, t { '' })
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

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
        {
            t{'if ('}, i(1, 'condition'), t{') {', ''},
                d(2, saved_text, {}, {indent = true}),
            t{'', '}'},
            d(3, else_clause, {}, {}),
        }
    ),
    s('elif', {
        t{'else if ('}, i(1, 'condition'), t{') {', ''},
            d(2, saved_text, {}, {indent = true}),
        t{'', '}'},
    }),
    s('for', {
        t{'for ('},
            i(1, 'i'), t{' = '}, i(2, '1'), t{'; '},
            i(3, 'i'), t{' '}, i(4, '<='), t{' '},  i(5, '10'), t{'; '},
            i(6, '++i'), t{') {'},
            d(7, saved_text, {}, {indent = true}),
        t{'', '}'},
    }),
    s('wh', {
        t{'while ('}, i(1, 'condition'), t{') {'},
            d(2, saved_text, {}, {indent = true}),
        t{'', '}'},
    }),
    s('fun', {
        c(1, {
            i(1, 'int'),
            i(1, 'char*'),
            i(1, 'float'),
            i(1, 'long'),
        }),
        t{' '}, i(2, 'name'), t{'('},
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
        t{') {', ''},
            d(5, saved_text, {}, {indent = true}),
        t{'', '}'},
    }),
}

return snippets
