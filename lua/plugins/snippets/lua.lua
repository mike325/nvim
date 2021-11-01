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
-- local l = require("luasnip.extras").lambda
-- local r = require("luasnip.extras").rep
-- local p = require('luasnip.extras').partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty
-- local dl = require("luasnip.extras").dynamic_lambda
-- local fmt = require("luasnip.extras.fmt").fmt
-- local fmta = require("luasnip.extras.fmt").fmta
-- local types = require("luasnip.util.types")
-- local events = require("luasnip.util.events")
-- local conds = require("luasnip.extras.expand_conditions")

local saved_text = RELOAD('plugins.snippets.utils').saved_text
local get_comment = require('plugins.snippets.utils').get_comment
local surround_with_func = require('plugins.snippets.utils').surround_with_func

-- TODO: Improve snippets like fun/lfun, map/set_m, cmd/set_c and au/set_au using regex and dynamic_node
-- stylua: ignore
ls.snippets.lua = {
    s("for", {
        t({"for "}), i(1, 'idx'), t({", "}), i(2, 'v'), t({" in ipairs("}), i(3, 'tbl'), t({") do", ""}),
           d(4, saved_text, {}, {indent = true}),
        t({"", "end"}),
    }),
    s("forp", {
        t({"for "}), i(1, 'k'), t({", "}), i(2, 'v'), t({" in pairs("}), i(3, 'tbl'), t({") do", ""}),
           d(4, saved_text, {}, {indent = true}),
        t({"", "end"}),
    }),
    s("fori", {
        t({"for idx = "}), i(1, '1'), t({", "}), i(2, '#limit'), t({" do", ""}),
           d(3, saved_text, {}, {indent = true}),
        t({"", "end"}),
    }),
    s("if", {
        t({"if "}), i(1, 'condition'), t({" then", ""}),
           d(2, saved_text, {}, {indent = true}),
        t({"", "end"}),
    }),
    s("ife", {
        t({"if "}), i(1, 'condition'), t({" then", ""}),
           d(2, saved_text, {}, {indent = true}),
        t({"", "else", ""}),
            t({'\t'}), i(3, get_comment('code')),
        t({"", "end"}),
    }),
    s("fun", {
        t({"function "}), i(1, 'name'), t({"("}), i(2, 'args'), t({")", ""}),
           d(3, saved_text, {}, {indent = true}),
        t({"", "end"}),
    }),
    s("lfun", {
        t({"local function "}), i(1, 'name'), t({"("}), i(2, 'args'), t({")", ""}),
           d(3, saved_text, {}, {indent = true}),
        t({"", "end"}),
    }),
    s("err", {
        t({"error(debug.traceback("}), d(1, surround_with_func, {}, {text = 'msg'}), t({"))"})
    }),
    s("req", {
        t({"require '"}), i(1, 'module'), t({"'"})
    }),
    s("l", {
        t({"local "}), i(1, 'var'), t({" = "}), i(2, 'value'),
    }),
    s("ign", {
        t({"-- stylua: ignore"})
    }),
    s("sty", {
        t({"-- stylua: ignore"})
    }),
    s("map", {
        t({"set_mapping {", ""}),
            t({"\tmode = '"}), i(1, 'n'), t({"',", ""}),
            t({"\tlhs = '"}),  i(2, '<C-q>'), t({"',", ""}),
            t({"\trhs = '"}),  i(3, 'lua P(true)'), t({"',", ""}),
            t({"\targs = { "}), i(4, 'noremap = true'), t({"},", ""}),
        t({"}"}),
    }),
    s("com", {
        t({"set_command {", ""}),
            t({"\tlhs = '"}),  i(1, 'Command'), t({"',", ""}),
            t({"\trhs = '"}),  i(2, 'lua P(true)'), t({"',", ""}),
            t({"\targs = { force = true, "}), i(3, "nargs = '?', "), t({"},", ""}),
        t({"}"}),
    }),
    s("au", {
        t({"set_autocmd {", ""}),
            t({"\tevent = '"}),   i(1, 'FileType'), t({"',", ""}),
            t({"\tpattern = '"}), i(2, '*'), t({"',", ""}),
            t({"\tcmd = '"}),     i(3, 'lua P(true)'), t({"',", ""}),
            t({"\tgroup = '"}),   i(4, 'NewGroup'), t({"',", ""}),
        t({"}"}),
    }),
    s("lext", {
        t({"vim.list_extend("}),
            d(1, surround_with_func, {}, {text = 'tbl'}),
        t({', {'}), i(2, "'node'"), t({'})'})
    }),
    s("text", {
        t({"vim.tbl_extend("}),
            c(1, { t({"'force'"}), t({"'keep'"}), t({"'error'"}) }),
            t({', '}),
            d(2, surround_with_func, {}, {text = 'tbl'}),
         t({', '}), i(3, "ext_tbl"), t({')'})
    }),
    s("not", {
        t({"vim.notify("}),
            d(1, surround_with_func, {}, {text = 'msg'}),
            t({', '}),
            c(2, { t({"'INFO'"}), t({"'WARN'"}), t({"'ERROR'"}), t({"'DEBUG'"}) }),
            c(3, { t{''}, sn(nil, { t{', { title = '}, i(1, "'title'"), t{' }'} }) } ),
         t({')'})
    }),
}
