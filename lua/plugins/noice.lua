-- local nvim = require 'neovim'
local load_module = require('utils.functions').load_module

local noice = load_module 'noice'
if not noice or vim.g.started_by_firenvim then
    return false
end

local routes = {}

-- TODO: routes fugitive and long shell messages like pre-commit
-- filter annoying messages
local hidden_text = {
    '%[w%]',
    'writter',
    'fewer line',
    'less line',
    '1 change;',
    'more lines?',
    'yanked',
}
for _, msg in ipairs(hidden_text) do
    table.insert(routes, {
        filter = {
            event = 'msg_show',
            kind = '',
            find = msg,
        },
        opts = { skip = true },
    })
end

noice.setup {
    lsp = {
        -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
        override = {
            ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
            ['vim.lsp.util.stylize_markdown'] = true,
            ['cmp.entry.get_documentation'] = true,
        },
    },
    presets = {
        bottom_search = false,
        command_palette = true,
        long_message_to_split = true,
        inc_rename = true,
        lsp_doc_border = true,
    },
    routes = routes,
}
