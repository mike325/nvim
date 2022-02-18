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
local l = require('luasnip.extras').lambda
-- local r = require('luasnip.extras').rep
local p = require('luasnip.extras').partial
-- local m = require('luasnip.extras').match
-- local n = require('luasnip.extras').nonempty
local dl = require('luasnip.extras').dynamic_lambda
-- local fmt = require('luasnip.extras.fmt').fmt
-- local fmta = require('luasnip.extras.fmt').fmta
-- local types = require 'luasnip.util.types'
-- local events = require 'luasnip.util.events'
-- local conds = require 'luasnip.extras.expand_conditions'

local utils = RELOAD 'plugins.snippets.utils'
local saved_text = utils.saved_text
-- local get_comment = utils.get_comment
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

local function else_clause(args, snip, old_state, placeholder)
    local nodes = {}

    if snip.captures[1] == 'e' then
        table.insert(nodes, t { '', 'else', '\t' })
        table.insert(nodes, i(1, 'pass'))
    else
        table.insert(nodes, t { '' })
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

-- stylua: ignore
ls.snippets.python = {
    s("for", {
        t{"for "}, i(1, 'i'), t{" in "}, i(2, 'Iterator'), t{":", ""},
            d(3, saved_text, {}, {text = 'pass', indent = true}),
    }),
    s("ran", {
        t{"range("}, i(1, '0'), t{", "}, i(2, 'limit'), t{")"},
    }),
    s("imp", {
        t{'import '}, i(1, 'sys')
    }),
    s(
        { trig = 'fro(m?)', regTrig = true },
        {
            t{'from '}, i(1, 'os'), t{' import '}, i(2, 'path')
        }
    ),
    s(
        { trig = "if(e?)", regTrig = true },
        {
            t{"if "}, i(1, 'condition'), t{":", ""},
                d(2, saved_text, {}, {text = 'pass', indent = true}),
            d(3, else_clause, {}, {}),
        }
    ),
    s('def', {
        t{'def '}, i(1, 'name'), t{'('},
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
            i(2, 'args'), t{'):', ''},
                d(3, saved_text, {}, {text = 'pass', indent = true}),
    }),
    s("try", {
        t{"try:", "",},
            d(1, saved_text, {}, {text = 'pass', indent = true}),
        t{"", "except "},
            c(2, {
                t{'Exception as e'},
                t{'KeyboardInterrupt as e'},
                sn(nil, { i(1, 'Exception') }),
            }),
        t{":", "\t"},
            i(3, 'pass'),
    }),
    s("ifmain", {
        t{'if __name__ == "__main__":', '\t'},
            c(1, {
                sn(nil, { t{'exit('}, i(1, 'main()'), t{')'} }),
                t{'pass'},
            }),
        t{"", "else:", "\t"},
            i(2, 'pass'),
    }),
    s("with", {
        t{"with open("}, i(1, 'filename'), t{', '},
        c(2, {
            i(1, '"r"'),
            i(1, '"a"'),
            i(1, '"w"'),
        }),
        t{') as '}, i(3, 'data'), t{':', ''},
            d(4, saved_text, {}, {text = 'pass', indent = true}),
    }),
    s("w", {
        t{"while "}, i(1, 'True'), t{":", ""},
            d(2, saved_text, {}, {text = 'pass', indent = true}),
    }),
    s(
        { trig = "(d?)cl", regTrig = true },
        {
            d(1, python_dataclass, {}, {}),
            t{"class "}, i(2, 'Class'), t{"("},
            c(3, {
                t{''},
                i(1, 'object'),
            }),
            t{"):", '\t"""'},
            dl(4, l._1 .. ': docstring', { 2 }),
            t{'"""', ''},
            d(5, python_class_init, {}, {}),
        }
    ),
}
