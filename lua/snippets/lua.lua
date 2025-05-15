local ls = vim.F.npcall(require, 'luasnip')
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
local p = require('luasnip.extras').partial
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
local surround_with_func = utils.surround_with_func

local function rec_val()
    return sn(nil, {
        c(1, {
            t { '' },
            sn(nil, {
                t { '', '\t' },
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
                t { ' },' },
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
                    local name = vim.split(module[1][1], '.', { trimempty = true })
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

-- TODO: Add pcall snippet and use TS to parse saved function and separate the function name and the args
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
            d(3, saved_text, {}, { user_args = { { indent = true } } }),
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
        d(4, saved_text, {}, { user_args = { { indent = true } } }),
    })),
    s('forp', fmt([[
    for {}, {} in pairs({}) do
    {}
    end
    ]], {
        i(1, 'k'),
        i(2, 'v'),
        i(3, 'tbl'),
        d(4, saved_text, {}, { user_args = { { indent = true } } }),
    })),
    s('fori', fmt([[
    for {} = {}, {} do
    {}
    end
    ]], {
        i(1, 'idx'),
        i(2, '0'),
        i(3, '10'),
        d(4, saved_text, {}, { user_args = { { indent = true } } }),
    })),
    s(
        { trig = "if(e?)", regTrig = true },
        {
            t { "if " }, i(1, 'condition'), t { " then", "" },
            d(2, saved_text, {}, { user_args = { { indent = true } } }),
            d(3, else_clause, {}, {}),
            t { "", "end" },
        }
    ),
    s('w', fmt([[
    while {} do
    {}
    end
    ]], {
        i(1, 'true'),
        d(2, saved_text, {}, { user_args = { { indent = true } } }),
    })),
    s('elif', fmt([[
    elseif {} then
    {}
    ]], {
        i(1, 'condition'),
        d(2, saved_text, {}, { user_args = { { indent = true } } }),
    })),
    s('elseif', fmt([[
    elseif {} then
    {}
    ]], {
        i(1, 'condition'),
        d(2, saved_text, {}, { user_args = { { indent = true } } }),
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
    s("ign", { t { "-- stylua: ignore" } }),
    s("sty", { t { "-- stylua: ignore" } }),
    s("val", {
        t({ "vim.validate {" }),
        t { '', "\t" }, i(1, 'arg'), t { " = { " }, r(1), t { ", " },
        c(2, {
            i(1, "'string'"),
            i(1, "'table'"),
            i(1, "'function'"),
            i(1, "'number'"),
            i(1, "'boolean'"),
        }),
        c(3, {
            t { "" },
            t { ", true" },
        }),
        t({ " }," }),
        d(4, rec_val, {}),
        t({ '', "}" }),
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
    s('aug', fmt([[
    vim.api.nvim_create_augroup('{}', {{ clear = {} }})
    ]], {
        i(1, 'GroupID'),
        c(2, {
            t { 'true' },
            t { 'false' },
        }),
    })),
    s('au', fmt([[
    vim.api.nvim_create_autocmd({{ '{}' }}, {{
        desc = '{}',
        group = {},
        pattern = '{}',
        -- callback = function(event) end,
    }})
    ]], {
        i(1, 'BufEnter'),
        i(2, 'description'),
        c(3, {
            t { 'group_id' },
            sn(nil, {
                t { "vim.api.nvim_create_augroup('" },
                i(1, 'GroupName'),
                t { "', { " },
                i(2, 'clear = true'),
                t { " })" },
            }),
        }),
        i(4, 'pattern'),
    })),
    s('lext', fmt([[vim.list_extend({}, {})]], {
        d(1, surround_with_func, {}, { user_args = { { text = 'tbl' } } }),
        i(2, "'node'"),
    })),
    s('text', fmt([[vim.tbl_extend('{}', {}, {})]], {
        c(1, {
            t { 'force' },
            t { 'keep' },
            t { 'error' },
        }),
        d(2, surround_with_func, {}, { user_args = { { text = 'tbl' } } }),
        i(3, "'node'"),
    })),
    s('not', fmt([[vim.notify('{}', {}{})]], {
        d(1, surround_with_func, {}, { user_args = { { text = 'msg' } } }),
        c(2, {
            t { 'vim.log.levels.INFO' },
            t { 'vim.log.levels.WARN' },
            t { 'vim.log.levels.ERROR' },
            t { 'vim.log.levels.DEBUG' },
        }),
        c(3, {
            t { '' },
            sn(nil, { t { ', { title = ' }, i(1, "'title'"), t { ' }' } }),
        }),
    })),
    s('use', fmt([[use {{ '{}' }}]], {
        i(1, 'plugin'),
    })),
    s('desc', fmt([[
    describe('{}', function()
        it('{}', function()
            {}
        end)
    end)
    ]], {
        i(1, 'DESCRIPTION'),
        i(2, 'DESCRIPTION'),
        i(3, '-- test'),
    })),
    s('it', fmt([[
    it('{}', function()
        {}
    end)
    ]], {
        i(1, 'DESCRIPTION'),
        i(2, '-- test'),
    })),
    s('pr', fmt([[print({})]], {
        i(1, 'msg'),
    })),
    -- TODO: Add support for mini tests
    -- s(
    --     { trig = '(n?)eq', regTrig = true },
    --     fmt([[assert.{}({}, {})]],{
    --     f(function(_, snip)
    --         -- stylua: ignore
    --         if snip.captures[1] == 'n' then
    --             -- stylua: ignore
    --             return 'are_not.same('
    --         end
    --         -- stylua: ignore
    --         return 'are.same('
    --     end, {}),
    --     i(1, 'expected'),
    --     i(2, 'result'),
    -- })),
    -- s(
    --     { trig = '(n?)eq', regTrig = true },
    --     fmt([[assert.{}({}, {})]],{
    --     f(function(_, snip)
    --         -- stylua: ignore
    --         if snip.captures[1] == 'n' then
    --             -- stylua: ignore
    --             return 'are_not.equal('
    --         end
    --         -- stylua: ignore
    --         return 'are.equal('
    --     end, {}),
    --     i(1, 'expected'),
    --     i(2, 'result'),
    -- })),
    -- s('haserr', fmt([[assert.has.error(function() {} end{})]],{
    --     i(1, 'error()'),
    --     c(2, {
    --         t{''},
    --         sn(nil, { t{", '"}, i(1, 'error'), t{"'"} }),
    --     }),
    -- })),
    -- s(
    --     { trig = 'is(_?)true', regTrig = true },
    --     fmt([[assert.is_true({})]], {
    --         d(1, surround_with_func, {}, {user_args = {{text = 'true'}}}),
    --     }
    -- )),
    -- s(
    --     { trig = 'is(_?)false', regTrig = true },
    --     fmt([[assert.is_false({})]], {
    --         d(1, surround_with_func, {}, {user_args = {{text = 'false'}}}),
    --     }
    -- )),
    -- s('istruthy', fmt([[assert.is_truthy({})]],{ d(1, surround_with_func, {}, {user_args = {{text = 'true'}}}), })),
    -- s('isfalsy', fmt([[assert.is_falsy({})]],{ d(1, surround_with_func, {}, {user_args = {{text = 'false'}}}), })),
    -- s('truthy', fmt([[assert.is_truthy({})]],{ d(1, surround_with_func, {}, {user_args = {{text = 'true'}}}), })),
    -- s('falsy', fmt([[assert.is_falsy({})]],{ d(1, surround_with_func, {}, {user_args = {{text = 'false'}}}), })),
    s(
        { trig = 'error' },
        fmt([[error(debug.traceback({}))]], {
            i(1, 'msg'),
        }
        )),
    s(
        { trig = 'ass' },
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
        fmt([[local {} = vim.F.npcall({})]], {
            i(1, 'module'),
            c(2, {
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
    s(
        { trig = 'cli' }, fmt([[
        #!{}

        local cli_setup
        local error_msg

        cli_setup = pcall(require, 'cli')
        if not cli_setup then
            local config_dir = (vim.fn.stdpath('config'):gsub('\\', '/'))
            local host_dir = string.format('%s/site/pack/host/start/host/', (vim.fn.stdpath('data'):gsub('\\', '/')))
            vim.opt.runtimepath:append {{ config_dir, host_dir }}
            cli_setup, error_msg = pcall(require, 'cli')
            if not cli_setup then
                error(debug.traceback(error_msg))
            end
        end

        local log = require('cli.logger'):new()

        ]], {
            p(function()
                if require('sys').name ~= 'windows' then
                    local env_version = vim.version.parse(vim.fn.system('env --version'))
                    if vim.version.ge(env_version, {8, 30})  then
                        local env_path = require('utils.files').exepath('env')
                        return string.format('%s -S nvim -l', env_path)
                    end
                end
                return string.format('%s -l', vim.v.progpath)
            end),
        }
        )),
}
