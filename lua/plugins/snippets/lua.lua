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
local f = ls.function_node
local c = ls.choice_node
local d = ls.dynamic_node
-- local l = require('luasnip.extras').lambda
local r = require('luasnip.extras').rep
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
local surround_with_func = utils.surround_with_func

local function else_clause(args, snip, old_state, placeholder)
    local nodes = {}

    if snip.captures[1] == 'e' then
        table.insert(nodes, t { '', 'else', '\t' })
        table.insert(nodes, i(1, get_comment 'code'))
    else
        table.insert(nodes, t { '' })
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

local function rec_val()
    return sn(nil, {
        c(1, {
            t { '' },
            sn(nil, {
                t { ',', '\t' },
                i(1, 'arg'),
                t { ' = { ' },
                r(1),
                t { ', ' },
                c(2, {
                    i(1, "'string'"),
                    i(1, "'table'"),
                    i(1, "'function'"),
                    i(1, "'number'"),
                    i(1, "'boolean'"),
                }),
                c(3, {
                    t { '' },
                    t { ', true' },
                }),
                t { ' }' },
                d(4, rec_val, {}),
            }),
        }),
    })
end

-- stylua: ignore
ls.snippets.lua = {
    s("for", {
        t{"for "}, i(1, 'idx'), t{", "}, i(2, 'v'), t{" in ipairs("}, i(3, 'tbl'), t{") do", ""},
            d(4, saved_text, {}, {indent = true}),
        t{"", "end"},
    }),
    s("forp", {
        t{"for "}, i(1, 'k'), t{", "}, i(2, 'v'), t{" in pairs"}, i(3, 'tbl'), t({" do", ""}),
            d(4, saved_text, {}, {indent = true}),
        t{"", "end"},
    }),
    s("fori", {
        t{"for idx = "}, i(1, '1'), t{", "}, i(2, '#limit'), t{" do", ""},
            d(3, saved_text, {}, {indent = true}),
        t{"", "end"},
    }),
    s(
        { trig = "if(e?)", regTrig = true },
        {
            t{"if "}, i(1, 'condition'), t{" then", ""},
                d(2, saved_text, {}, {indent = true}),
            d(3, else_clause, {}, {}),
            t{"", "end"},
        }
    ),
    s('elif', {
        t{"elseif "}, i(1, 'condition'), t{" then", ""},
            d(2, saved_text, {}, {indent = true}),
    }),
    s(
        { trig = "(l?)fun", regTrig = true },
        {
            f(function(_, snip)
                -- stylua: ignore
                return snip.captures[1] == 'l' and 'local ' or ''
            end, {}),
            t{"function "}, i(1, 'name'), t{"("}, i(2, 'args'), t{")", ""},
                d(3, saved_text, {}, {indent = true}),
            t{"", "end"},
        }
    ),
    s("err", {
        t{"error(debug.traceback("}, d(1, surround_with_func, {}, {text = 'msg'}), t{"))"}
    }),
    s("req", {
        t{"require '"}, i(1, 'module'), t{"'"}
    }),
    s("l", {
        t{"local "}, i(1, 'var'), t{" = "}, i(2, '{}'),
    }),
    s("ign", {
        t{"-- stylua: ignore"}
    }),
    s("sty", {
        t{"-- stylua: ignore"}
    }),
    s("map", {
        t{"vim.keymap.set("},
            t{"'"}, i(1, 'n'), t{"', "},
            t{"\t'"}, i(2, 'LHS'), t{"', "},
            t{"\t'"}, i(3, 'RHS'), t{"', "},
            t{"\t{"}, i(4, 'noremap = true'), t{"}"},
        t{")"},
    }),
    s("val", {
        t({"vim.validate {"}),
            t{'', "\t"}, i(1, 'arg'), t{" = { "}, r(1), t{", "},
                c(2, {
                    i(1, "'string'"),
                    i(1, "'table'"),
                    i(1, "'function'"),
                    i(1, "'number'"),
                    i(1, "'boolean'"),
                }),
                c(3, {
                    t{""},
                    t{", true"},
                }),
            t({" }"}),
            d(4, rec_val, {}),
        t({'', "}"}),
    }),
    s("com", {
        t{"set_command {", ""},
            t{"\tlhs = '"},  i(1, 'Command'), t{"',", ""},
            t{"\trhs = '"},  i(2, 'lua P(true)'), t{"',", ""},
            t{"\targs = { force = true, "}, i(3, "nargs = '?', "), t{"},", ""},
        t{"}"},
    }),
    s("au", {
        t{"set_autocmd {", ""},
            t{"\tevent = '"},   i(1, 'FileType'), t{"',", ""},
            t{"\tpattern = '"}, i(2, '*'), t{"',", ""},
            t{"\tcmd = '"},     i(3, 'lua P(true)'), t{"',", ""},
            t{"\tgroup = '"},   i(4, 'NewGroup'), t{"',", ""},
        t{"}"},
    }),
    s("lext", {
        t{"vim.list_extend("},
            d(1, surround_with_func, {}, {text = 'tbl'}),
        t{', {'}, i(2, "'node'"), t{'})'},
    }),
    s("text", {
        t{"vim.tbl_extend("},
            c(1, {
                t{"'force'"},
                t{"'keep'"},
                t{"'error'"},
            }),
            t{', '},
            d(2, surround_with_func, {}, {text = 'tbl'}),
         t{', '}, i(3, "ext_tbl"), t({')'})
    }),
    s('not', {
        t{'vim.notify('},
            d(1, surround_with_func, {}, {text = 'msg'}),
            t{', '},
            c(2, {
                t{"'INFO'"},
                t{"'WARN'"},
                t{"'ERROR'"},
                t{"'DEBUG'"},
            }),
            c(3, {
                t{''},
                sn(nil, { t{', { title = '}, i(1, "'title'"), t{' }'} }),
            }),
         t{')'},
    }),
    s('use', {
        t{"use { '"},
            i(1, 'author/plugin'),
         t{" '}"},
    }),
    s('desc', {
        t{"describe('"}, i(1, 'DESCRIPTION'), t{"', function()", ''},
            t{"\tit('"}, i(2, 'DESCRIPTION'), t{"', function()", ''},
                t{'\t\t'},   i(3, '-- test'), t{'', ''},
            t{'\tend)', ''},
        t{'end)'},
    }),
    s('it', {
        t{"it('"}, i(1, 'DESCRIPTION'), t{"', function()", ''},
            t{'\t'},   i(2, '-- test'), t{'', ''},
        t{'end)'},
    }),
}
