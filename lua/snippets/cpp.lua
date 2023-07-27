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

if #ls.get_snippets 'c' == 0 then
    ls.add_snippets('c', require 'snippets.c')
end

local utils = RELOAD 'plugins.luasnip.utils'
local saved_text = utils.saved_text
local add_statement_and_include = utils.add_statement_and_include
-- local get_comment = utils.get_comment
-- local surround_with_func = utils.surround_with_func

ls.filetype_extend('cpp', { 'c' })

local function smart_ptr(_, snip)
    local cpp = RELOAD 'utils.treesitter.cpp'
    local qt_ptr = snip.captures[1] == 'q'
    local is_uniq = snip.captures[2] == 'u'

    local ptr
    if qt_ptr and not is_uniq then
        cpp.add_include('qt5/QtCore/QSharedPointer', 'sys')
        ptr = 'QSharedPointer'
    else
        cpp.add_include('memory', 'sys')
        if not qt_ptr and not is_uniq then
            ptr = 'std::shared_ptr'
        else
            ptr = 'std::unique_ptr'
        end
    end

    return ptr
end
local function chrono_sleep(_, parent, old_state)
    local cpp = RELOAD 'utils.treesitter.cpp'
    cpp.add_include('chrono', 'sys')
    cpp.add_include('thread', 'sys')

    local nodes = {}
    vim.list_extend(nodes, {
        c(1, {
            i(1, 'nanoseconds'),
            i(1, 'microseconds'),
            i(1, 'milliseconds'),
            i(1, 'seconds'),
            i(1, 'minutes'),
            i(1, 'hours'),
        }),
    })

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

local function get_move_copy_functions()
    local class_node = RELOAD('utils.treesitter').get_current_class()
    if not class_node then
        vim.notify('Cursor is not inside a class', 'ERROR')
        return {}
    end

    return RELOAD('utils.treesitter.cpp').get_class_operators(true)
end

local function get_classname()
    local class = RELOAD('utils.treesitter').get_current_class()
    if not class then
        vim.notify('Cursor is not inside a class', 'ERROR')
        return 'Class'
    end
    local classname_query = [[
        (class_specifier (type_identifier) @name)
        (struct_specifier (type_identifier) @name)
    ]]

    local buf = vim.api.nvim_get_current_buf()

    local node
    local pos = { class[2] - 1, class[3] - 1 }

    -- DEPRECATED: vim.treesitter.(parse_query/query.parse_query/get_node_...) in 0.9
    local parse_func = vim.treesitter.query.parse or vim.treesitter.query.parse_query
    local get_node_text = vim.treesitter.get_node_text or vim.treesitter.query.get_node_text
    if vim.treesitter.get_node then
        node = vim.treesitter.get_node { bufnr = buf, pos = pos }
    else
        node = vim.treesitter.get_node_at_pos(buf, pos[1], pos[2], {})
    end

    local classname = ''
    local query = parse_func(vim.opt_local.filetype:get(), classname_query)
    for _, capture, _ in query:iter_captures(node, buf) do
        -- NOTE: Should match just once
        classname = get_node_text(capture, buf)
    end

    return classname
end

local function rule_3_5(_, parent, old_state)
    local classname = get_classname()

    local choice_nr = 0
    local function get_choice()
        choice_nr = choice_nr + 1
        return c(choice_nr, {
            t { ' = delete' },
            t { ' = default' },
            t { '' },
        })
    end

    local nodes = {}

    local operators = get_move_copy_functions()

    local copy_contructor = false
    local copy_oper = false
    local move_contructor = false
    local move_oper = false
    local destructor = false

    for _, method in ipairs(operators) do
        local signature = vim.trim(method[1])
        if signature:match('virtual ~' .. classname .. '%s*%(') or signature:match('~' .. classname .. '%s*%(') then
            destructor = true
        elseif signature:match(classname .. '%s*%(%w*%s*' .. classname .. '&&') then
            move_contructor = true
        elseif signature:match(classname .. '%s*&%s*operator=%(%w*%s*' .. classname .. '&&') then
            move_oper = true
        elseif signature:match(classname .. '%s*%(%w*%s*' .. classname .. '&') then
            copy_contructor = true
        elseif signature:match(classname .. '%s*&%s*operator=%(%w*%s*' .. classname .. '&') then
            copy_oper = true
        end
    end

    -- local space = false
    if parent.captures[1] ~= '' then
        if not destructor then
            choice_nr = choice_nr + 1
            vim.list_extend(nodes, {
                c(choice_nr, {
                    t { '' },
                    t { 'virtual ' },
                }),
                t { '~' },
                t { classname },
                t { '()' },
                get_choice(),
                t { ';' },
            })
        end

        if not copy_contructor then
            vim.list_extend(nodes, {
                t { '', '' },
                t { classname },
                t { '(const ' },
                t { classname },
                t { '&)' },
                get_choice(),
                t { ';' },
            })
        end

        if not copy_oper then
            vim.list_extend(nodes, {
                t { '', '' },
                t { classname },
                t { '& operator=(const ' },
                t { classname },
                t { '&)' },
                r(choice_nr),
                t { ';' },
            })
        end
    end

    if parent.captures[1] == '5' then
        if not move_contructor then
            vim.list_extend(nodes, {
                t { '', '' },
                t { classname },
                t { '(const ' },
                t { classname },
                t { '&&)' },
                get_choice(),
                t { ';' },
            })
        end

        if not move_oper then
            vim.list_extend(nodes, {
                t { '', '' },
                t { classname },
                t { '& operator=(const ' },
                t { classname },
                t { '&&)' },
                r(choice_nr),
                t { ';' },
            })
        end
    end

    local snip_node = sn(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
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
    -- TODO: This could be smarter, and add only the missing functions
    s({ trig = 'rl?([35])', regTrig = true }, {
        d(1, rule_3_5, {}, {}),
    }),
    s(
        { trig = '(t?)cl', regTrig = true },
        fmt(
            [[
            class {} final
            {{
            public:
            }};
        ]],
            {
                i(1, 'Class'),
            }
        )
    ),
    -- TODO: There's should be a way to have the same login in cl3/5 and have dynamic class names changes
    s(
        { trig = '(t?)cl3', regTrig = true },
        fmt(
            [[
            class {} final
            {{
            public:
                {}(){};
                ~{}(){};
                {}(const {}&){};
                {}& operator=(const {}&){};
            }};
        ]],
            {
                i(1, 'Class'),
                r(1),
                c(2, {
                    t { ' = delete' },
                    t { ' = default' },
                    t { '' },
                }),
                r(1),
                c(3, {
                    t { ' = delete' },
                    t { ' = default' },
                    t { '' },
                }),
                r(1),
                r(1),
                c(4, {
                    t { ' = delete' },
                    t { ' = default' },
                    t { '' },
                }),
                r(1),
                r(1),
                r(4),
            }
        )
    ),
    s(
        { trig = '(t?)cl5', regTrig = true },
        fmt(
            [[
            class {} final
            {{
            public:
                {}(){};
                ~{}(){};
                {}(const {}&){};
                {}& operator=(const {}&){};
                {}({}&&){};
                {}& operator=({}&&){};
            }};
        ]],
            {
                i(1, 'Class'),
                r(1),
                c(2, {
                    t { ' = delete' },
                    t { ' = default' },
                    t { '' },
                }),
                r(1),
                c(3, {
                    t { ' = delete' },
                    t { ' = default' },
                    t { '' },
                }),
                r(1),
                r(1),
                c(4, {
                    t { ' = delete' },
                    t { ' = default' },
                    t { '' },
                }),
                r(1),
                r(1),
                r(4),
                r(1),
                r(1),
                c(5, {
                    t { ' = delete' },
                    t { ' = default' },
                    t { '' },
                }),
                r(1),
                r(1),
                r(5),
            }
        )
    ),
    s(
        'enum',
        fmt(
            [[
        enum class {}
        {{
            {};
        }}
        ]],
            {
                i(1, 'EClass'),
                i(2, 'ONE'),
            }
        )
    ),
    s(
        'swi',
        fmt(
            [[
        switch({})
        {{
        case {}:
            break;
        default:
            break;
        }}
        ]],
            {
                i(1, 'var'),
                i(2, 'CASE'),
            }
        )
    ),
    s(
        'case',
        fmt(
            [[
        case {}:
            break;
        ]],
            {
                i(1, 'CASE'),
            }
        )
    ),
    s(
        'sst',
        fmt([[std::{} {}]], {
            p(add_statement_and_include, 'stringstream', 'sstream'),
            i(1, 'ss'),
        })
    ),
    s(
        'vec',
        fmt([[std::{}<{}> {}]], {
            p(add_statement_and_include, 'vector'),
            i(1, 'int'),
            i(2, 'v'),
        })
    ),
    s(
        'sv',
        fmt([[std::{} {}]], {
            p(add_statement_and_include, 'string_view'),
            i(1, 's'),
        })
    ),
    s(
        'str',
        fmt([[std::{} {}]], {
            p(add_statement_and_include, 'string'),
            i(1, 's'),
        })
    ),
    s(
        'co',
        fmt([[std::{} << {};]], {
            p(add_statement_and_include, 'cout', 'iostream'),
            i(1, '"msg"'),
        })
    ),
    s(
        'cer',
        fmt([[std::{} << {};]], {
            p(add_statement_and_include, 'cerr', 'iostream'),
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
                sn(nil, fmt('"{}"', { i(1, 'iostream') })),
                sn(nil, fmt('<{}>', { i(1, 'iostream') })),
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
        { trig = 'sleep', regTrig = false },
        fmt([[std::this_thread::sleep_for(std::chrono::{}({}));]], {
            d(1, chrono_sleep, {}, {}),
            i(2, '10'),
        })
    ),
    s(
        'find',
        fmt([[std::{}({}.begin(), {}.end(), {})]], {
            p(add_statement_and_include, 'find', 'algorithm'),
            i(1, 'v'),
            r(1),
            i(2, 'n'),
        })
    ),
    s(
        'findi',
        fmt([[std::{}({}.begin(), {}.end(), [](decltype(*{}.begin()) {}){{ return {}; }})]], {
            p(add_statement_and_include, 'find_if', 'algorithm'),
            i(1, 'v'),
            r(1),
            r(1),
            i(2, 'it'),
            i(3, 'true'),
        })
    ),
    s(
        'cau',
        fmt([[const auto {};]], {
            i(1, 'v'),
        })
    ),
}
