local load_module = require'utils.helpers'.load_module

local luasnip = load_module'luasnip'

if not luasnip then
    return false
end

local s = luasnip.snippet
-- local sn = luasnip.snippet_node
local t = luasnip.text_node
local i = luasnip.insert_node
local f = luasnip.function_node
-- local c = luasnip.choice_node
-- local d = luasnip.dynamic_node
-- local l = require("luasnip.extras").lambda
-- local r = require("luasnip.extras").rep
local p = require("luasnip.extras").partial
-- local m = require("luasnip.extras").match
-- local n = require("luasnip.extras").nonempty

-- local nvim  = require'neovim'
local set_mapping = require'neovim.mappings'.set_mapping

-- local ts_locals = require "nvim-treesitter.locals"
-- local ts_utils = require "nvim-treesitter.ts_utils"

luasnip.config.set_config({
    history = true,
    -- Update more often, :h events for more info.
    updateevents = "TextChanged,TextChangedI",
})

local function copy(args)
    return args[1]
end

local function get_comment()
    local comment = vim.opt_local.commentstring:get()
    if not comment:match('%s%%s') then
        comment = comment:format(' %s')
    end
    return comment
end

local function notes(note)
    note = note:upper()
    if note:sub(#note, #note) ~= ':' then
        note = note..': '
    end
    return get_comment():format(note)
end

luasnip.snippets = {
    all = {
        -- trigger is fn.
        s("fn", {
            -- Simple static text.
            t("//Parameters: "),
            -- function, first parameter is the function, second the Placeholders
            -- whose text it gets as input.
            f(copy, 2),
            t({ "", "function " }),
            -- Placeholder/Insert.
            i(1),
            t("("),
            -- Placeholder with initial text.
            i(2, "int foo"),
            -- Linebreak
            t({ ") {", "\t" }),
            -- Last Placeholder, exit Point of the snippet. EVERY 'outer' SNIPPET NEEDS Placeholder 0.
            i(0),
            t({ "", "}" }),
        }),
        s("note", p(notes, "note")),
        s("todo", p(notes, "todo")),
        s("fix", p(notes, "fix")),
        s("fixme", p(notes, "fixme")),
        s("warn", p(notes, "warn")),
        s("bug", p(notes, "bug")),
        s("improve", p(notes, "improve")),
        -- s({ trig = "(" }, { t { "(" }, i(1), t { ")" }, i(0) }, neg, char_count_same, "%(", "%)"),
    }

}

-- TODO: Add missing mapping equivalent to ultisnips visual
-- snoremap <silent> <Tab> <cmd>lua require('luasnip').jump(1)<Cr>
-- snoremap <silent> <S-Tab> <cmd>lua require('luasnip').jump(-1)<Cr>
-- smap <silent><expr> <C-E> luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>'
set_mapping{
    mode = 'i',
    lhs = '<C-E>',
    rhs = [[luasnip#choice_active() ? '<Plug>luasnip-next-choice' : '<C-E>']],
    args = {noremap = true, expr = true, silent = true}
}

return true
