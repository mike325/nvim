local noice = vim.F.npcall(require, 'noice')
if not noice or vim.g.started_by_firenvim then
    return false
end

local routes = {}

-- TODO: routes fugitive and long shell messages like pre-commit
-- filter annoying messages
local hidden_text = {
    '%[w%]',
    'written',
    'fewer lines',
    'line less',
    '%d+ changes?;',
    'more lines?',
    'yanked',
    '%d+ lines?',
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
