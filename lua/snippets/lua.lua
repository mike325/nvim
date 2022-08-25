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
local fmt = require('luasnip.extras.fmt').fmt
-- local fmta = require('luasnip.extras.fmt').fmta
-- local types = require 'luasnip.util.types'
-- local events = require 'luasnip.util.events'
-- local conds = require 'luasnip.extras.expand_conditions'

local utils = RELOAD 'plugins.luasnip.utils'
local saved_text = utils.saved_text
local else_clause = utils.else_clause
local surround_with_func = utils.surround_with_func

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

local function require_import(_, parent, old_state)
    local nodes = {}

    local variable = parent.captures[1] == 'l'
    local call_func = parent.captures[2] == 'f'

    if variable then
        table.insert(nodes, t { 'local ' })
        if call_func then
            table.insert(nodes, r(2))
        else
            table.insert(
                nodes,
                f(function(module)
                    local name = vim.split(module[1][1], '.', true)
                    if name[#name] and name[#name] ~= '' then
                        return name[#name]
                    elseif #name - 1 > 0 and name[#name - 1] ~= '' then
                        return name[#name - 1]
                    end
                    return name[1] or 'module'
                end, { 1 })
            )
        end
        table.insert(nodes, t { ' = ' })
    end

    table.insert(nodes, t { 'require' })

    if call_func then
        table.insert(nodes, t { "('" })
        table.insert(nodes, i(1, 'module'))
        table.insert(nodes, t { "')." })
        table.insert(nodes, i(2, 'func'))
    else
        table.insert(nodes, t { " '" })
        table.insert(nodes, i(1, 'module'))
        table.insert(nodes, t { "'" })
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

-- TODO: Add pcall snippet and use TS to parse saved function and separete the funcion name and the args
-- stylua: ignore
return {
    s(
        { trig = "(l?)fun", regTrig = true },
        fmt([[
        {}function {}({})
        {}
        end
        ]], {
            f(function(_, snip)
                -- stylua: ignore
                return snip.captures[1] == 'l' and 'local ' or ''
            end, {}),
            i(1, 'name'),
            i(2, 'args'),
            d(3, saved_text, {}, {user_args = {{indent = true}}}),
        }
    )),
    s('for', fmt([[
    for {}, {} in ipairs({}) do
    {}
    end
    ]], {
        i(1, 'k'),
        i(2, 'v'),
        i(3, 'tbl'),
        d(4, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s('forp', fmt([[
    for {}, {} in pairs({}) do
    {}
    end
    ]], {
        i(1, 'k'),
        i(2, 'v'),
        i(3, 'tbl'),
        d(4, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s('fori', fmt([[
    for {} = {}, {} do
    {}
    end
    ]], {
        i(1, 'idx'),
        i(2, '0'),
        i(3, '10'),
        d(4, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s(
        { trig = "if(e?)", regTrig = true },
        {
            t{"if "}, i(1, 'condition'), t{" then", ""},
                d(2, saved_text, {}, {user_args = {{indent = true}}}),
            d(3, else_clause, {}, {}),
            t{"", "end"},
        }
    ),
    s('w', fmt([[
    while {} do
    {}
    end
    ]], {
        i(1, 'true'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s('elif', fmt([[
    elseif {} then
    {}
    ]],{
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s('elseif', fmt([[
    elseif {} then
    {}
    ]],{
        i(1, 'condition'),
        d(2, saved_text, {}, {user_args = {{indent = true}}}),
    })),
    s(
        { trig = '(l?)req(f?)', regTrig = true },
        {
            d(1, require_import, {}, {}),
        }
    ),
    s("l", fmt([[local {} = {}]], {
        i(1, 'var'),
        i(2, '{}'),
    })),
    s("ign", { t{"-- stylua: ignore"} }),
    s("sty", { t{"-- stylua: ignore"} }),
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
    s('command', fmt([[
    nvim.command.set({}, {}, {})
    ]], {
        i(1, 'name'),
        i(2, 'cmd'),
        i(3, 'opts'),
    })),
    s('map', fmt([[
    vim.keymap.set('{}', '{}', {}, {{ {} }})
    ]], {
            i(1, 'n'),
            i(2, 'LHS'),
            i(3, 'RHS'),
            i(4, ''),
    })),
    s('au', fmt([[
    nvim.autocmd.{} = {{
        event = '{}',
        pattern = '{}',
    }}
    ]], {
            i(1, 'AuGroup'),
            i(2, 'event'),
            i(3, 'pattern'),
    })),
    s('lext', fmt([[vim.list_extend({}, {})]],{
        d(1, surround_with_func, {}, {user_args = {{text = 'tbl'}}}),
        i(2, "'node'"),
    })),
    s('text', fmt([[vim.tbl_extend('{}', {}, {})]],{
        c(1, {
            t{'force'},
            t{'keep'},
            t{'error'},
        }),
        d(2, surround_with_func, {}, {user_args = {{text = 'tbl'}}}),
        i(3, "'node'"),
    })),
    s('not', fmt([[vim.notify('{}', '{}'{})]],{
        d(1, surround_with_func, {}, {user_args = {{text = 'msg'}}}),
        c(2, {
            t{'INFO'},
            t{'WARN'},
            t{'ERROR'},
            t{'DEBUG'},
        }),
        c(3, {
            t{''},
            sn(nil, { t{', { title = '}, i(1, "'title'"), t{' }'} }),
        }),
    })),
    s('use', fmt([[use {{ '{}' }}]],{
        i(1, 'plugin'),
    })),
    s('desc', fmt([[
    describe('{}', funcion()
        it('{}', funcion()
            {}
        end)
    end)
    ]],{
        i(1, 'DESCRIPTION'),
        i(2, 'DESCRIPTION'),
        i(3, '-- test'),
    })),
    s('it', fmt([[
    it('{}', funcion()
        {}
    end)
    ]],{
        i(1, 'DESCRIPTION'),
        i(2, '-- test'),
    })),
    s(
        { trig = '(n?)eq', regTrig = true },
        fmt([[assert.{}({}, {})]],{
        f(function(_, snip)
            -- stylua: ignore
            if snip.captures[1] == 'n' then
                -- stylua: ignore
                return 'are_not.same('
            end
            -- stylua: ignore
            return 'are.same('
        end, {}),
        i(1, 'expected'),
        i(2, 'result'),
    })),
    s(
        { trig = '(n?)eq', regTrig = true },
        fmt([[assert.{}({}, {})]],{
        f(function(_, snip)
            -- stylua: ignore
            if snip.captures[1] == 'n' then
                -- stylua: ignore
                return 'are_not.equal('
            end
            -- stylua: ignore
            return 'are.equal('
        end, {}),
        i(1, 'expected'),
        i(2, 'result'),
    })),
    s('haserr', fmt([[assert.has.error(function() {} end{})]],{
        i(1, 'error()'),
        c(2, {
            t{''},
            sn(nil, { t{", '"}, i(1, 'error'), t{"'"} }),
        }),
    })),
    s(
        { trig = 'is(_?)true', regTrig = true },
        fmt([[assert.is_true({})]], {
            d(1, surround_with_func, {}, {user_args = {{text = 'true'}}}),
        }
    )),
    s(
        { trig = 'is(_?)false', regTrig = true },
        fmt([[assert.is_false({})]], {
            d(1, surround_with_func, {}, {user_args = {{text = 'false'}}}),
        }
    )),
    s('pr', fmt([[print({})]],{
        i(1, 'msg'),
    })),
    s('istruthy', fmt([[assert.is_truthy({})]],{ d(1, surround_with_func, {}, {user_args = {{text = 'true'}}}), })),
    s('isfalsy', fmt([[assert.is_falsy({})]],{ d(1, surround_with_func, {}, {user_args = {{text = 'false'}}}), })),
    s('truthy', fmt([[assert.is_truthy({})]],{ d(1, surround_with_func, {}, {user_args = {{text = 'true'}}}), })),
    s('falsy', fmt([[assert.is_falsy({})]],{ d(1, surround_with_func, {}, {user_args = {{text = 'false'}}}), })),

    s(
        { trig = 'assert' },
        fmt([[assert({}, debug.traceback({}))]], {
            i(1, 'condition'),
            i(2, 'msg'),
        }
    )),
    s(
        { trig = 'debug' },
        fmt([[assert({}, debug.traceback({}))]], {
            i(1, 'condition'),
            i(2, 'msg'),
        }
    )),
    s(
        { trig = 'pcall' },
        fmt([[local {}, {} = pcall({})]], {
            c(1, {
                i(1, 'ok'),
                i(1, '_'),
            }),
            c(2, {
                i(1, 'module'),
                i(1, '_'),
            }),
            c(3, {
                sn(nil, {
                    i(1, 'func'),
                }),
                sn(nil, {
                    i(1, 'func'),
                    t { ', ' },
                    i(2, 'arg'),
                }),
            }),
        }
    )),
}
