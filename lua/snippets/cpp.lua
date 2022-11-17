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
local f = ls.function_node
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
    ls.add_snippets('c', require 'snippets.c')
end

local utils = RELOAD 'plugins.luasnip.utils'
local saved_text = utils.saved_text
-- local get_comment = utils.get_comment
-- local surround_with_func = utils.surround_with_func

ls.filetype_extend('cpp', { 'c' })

local function smart_ptr(_, snip)
    local qt_ptr = snip.captures[1] == 'q'
    local is_uniq = snip.captures[2] == 'u'

    local ptr
    if qt_ptr and not is_uniq then
        ptr = 'QSharedPointer'
    elseif not qt_ptr and not is_uniq then
        ptr = 'std::shared_ptr'
    else
        ptr = 'std::unique_ptr'
    end

    return ptr
end

return {
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
    s(
        { trig = '(q?)([us])_?ptr', regTrig = true },
        fmt([[{}<{}>]], {
            f(smart_ptr, {}),
            i(1, 'type'),
        })
    ),
    s(
        { trig = 'mfun', regTrig = true },
        fmt(
            [[
        {} {}::{}({}) {{
        {}
        }}
        ]],
            {
                c(1, {
                    i(1, 'int'),
                    i(1, 'char*'),
                    i(1, 'float'),
                    i(1, 'long'),
                }),
                i(2, 'Class'),
                i(3, 'funcname'),
                c(4, {
                    t { '' },
                    sn(nil, {
                        c(1, {
                            i(1, 'int'),
                            i(1, 'char*'),
                            i(1, 'float'),
                            i(1, 'long'),
                        }),
                        t { ' ' },
                        i(2, 'varname'),
                    }),
                }),
                d(5, saved_text, {}, { user_args = { { indent = true } } }),
            }
        )
    ),
}
