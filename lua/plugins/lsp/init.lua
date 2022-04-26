-- local nvim = require 'neovim'
local load_module = require('utils.helpers').load_module
local get_icon = require('utils.helpers').get_icon
-- local plugins = require'neovim'.plugins

local lsp = load_module 'lspconfig'

if lsp == nil then
    return false
end

local null_sources = {}
local null_ls = load_module 'null-ls'
local null_configs = require 'plugins.lsp.null'

if null_ls then
    table.insert(null_sources, null_ls.builtins.code_actions.gitsigns)
end

vim.diagnostic.config {
    signs = true,
    underline = true,
    update_in_insert = false,
    virtual_text = {
        spacing = 2,
        prefix = '❯',
    },
}

local lsp_sign = 'DiagnosticSign'
for _, level in pairs { 'Error', 'Hint', 'Warn', 'Info' } do
    vim.fn.sign_define(lsp_sign .. level, { text = get_icon(level:lower()), texthl = lsp_sign .. level })
    vim.cmd(
        ('sign define %s%s text=%s texthl=%s%s linehl= numhl='):format(
            lsp_sign,
            level,
            get_icon(level:lower()),
            lsp_sign,
            level
        )
    )
end

-- local original_set_virtual_text = vim.diagnostic.set_virtual_text
-- local set_virtual_text_custom = function(lsp_diagnostics, bufnr, client_id, sign_ns, opts)
--     opts = opts or {}
--     -- show all messages that are Warning and above (Warning, Error)
--     opts.severity_limit = 'Error'
--     original_set_virtual_text(lsp_diagnostics, bufnr, client_id, sign_ns, opts)
-- end
-- vim.diagnostic.set_virtual_text = set_virtual_text_custom

local lsp_configs = require 'plugins.lsp.servers'
local lsp_setup = require('plugins.lsp.utils').setup

vim.lsp.protocol.CompletionItemKind = {
    '', -- Text          = 1;
    '', -- Method        = 2;
    'ƒ', -- Function      = 3;
    '', -- Constructor   = 4;
    '識', -- Field         = 5;
    '', -- Variable      = 6;
    '', -- Class         = 7;
    'ﰮ', -- Interface     = 8;
    '', -- Module        = 9;
    '', -- Property      = 10;
    '', -- Unit          = 11;
    '', -- Value         = 12;
    '了', -- Enum          = 13;
    '', -- Keyword       = 14;
    '﬌', -- Snippet       = 15;
    '', -- Color         = 16;
    '', -- File          = 17;
    '渚', -- Reference     = 18;
    '', -- Folder        = 19;
    '', -- EnumMember    = 20;
    '', -- Constant      = 21;
    '', -- Struct        = 22;
    '鬒', -- Event         = 23;
    'Ψ', -- Operator      = 24;
    '', -- TypeParameter = 25;
}

for filetype, _ in pairs(lsp_configs) do
    local has_server = lsp_setup(filetype)
    local null_config = null_configs[filetype]

    if not has_server and null_config then
        vim.list_extend(null_sources, null_config.servers)
    end
end

if null_ls and next(null_sources) ~= nil then
    null_ls.setup {
        sources = null_sources,
        -- debug = true,
        on_attach = function(client, bufnr)
            require('plugins.lsp.config').on_attach(client, bufnr, true)
        end,
    }
end

return {
    setup = lsp_setup,
}
