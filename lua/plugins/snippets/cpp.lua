local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local s = ls.snippet
local sn = ls.snippet_node
-- local t = ls.text_node
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
local fmt = require('luasnip.extras.fmt').fmt
-- local fmta = require('luasnip.extras.fmt').fmta
-- local types = require 'luasnip.util.types'
-- local events = require 'luasnip.util.events'
-- local conds = require 'luasnip.extras.expand_conditions'

if #ls.get_snippets 'c' == 0 then
    require 'plugins.snippets.c'
end

local utils = RELOAD 'plugins.snippets.utils'
local saved_text = utils.saved_text
-- local get_comment = utils.get_comment
-- local surround_with_func = utils.surround_with_func

ls.filetype_extend('cpp', { 'c' })
ls.add_snippets('cpp', {
    s(
        'forr',
        fmt(
            [[
    for(const auto &{} : {}) {{
    {}
    }}
    ]],
            {
                i(1, 'v'),
                i(2, 'iterator'),
                d(3, saved_text, {}, { user_args = { { indent = true } } }),
            }
        )
    ),
    s(
        'vec',
        fmt([[std::vector<{}> {}]], {
            i(1, 'std::string'),
            i(2, 'v'),
        })
    ),
    s(
        'str',
        fmt([[std::{} {}]], {
            c(1, {
                i(1, 'string'),
                i(1, 'string_view'),
            }),
            i(2, 's'),
        })
    ),
    s(
        'co',
        fmt([[std::cout << {};]], {
            i(1, '"msg"'),
        })
    ),
    s(
        'cer',
        fmt([[std::cerr << {};]], {
            i(1, '"msg"'),
        })
    ),
    s(
        'con',
        fmt([[const {} {}]], {
            c(1, {
                i(1, 'auto'),
                i(1, 'std::string'),
            }),
            i(2, 'v'),
        })
    ),
    s('cex', fmt([[constexpr]], {})),
    s(
        'inc',
        fmt([[#include {}]], {
            c(1, {
                sn(nil, fmt('<{}>', { i(1, 'iostream') })),
                sn(nil, fmt('"{}"', { i(1, 'iostream') })),
            }),
        })
    ),
})

-- local clike = RELOAD 'plugins.snippets.c_like'
-- for _, csnip in ipairs(clike) do
--     local has_snip = false
--     for _, snip in ipairs(ls.snippets.c) do
--         if snip.dscr == csnip.dscr then
--             has_snip = true
--             break
--         end
--     end
--     if not has_snip then
--         table.insert(ls.snippets.c, csnip)
--     end
-- end
