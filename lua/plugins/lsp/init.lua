-- local nvim = require 'neovim'
local load_module = require('utils.functions').load_module
local get_icon = require('utils.functions').get_icon
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
    -- TODO: Simplify this abomination
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

local preload = {
    clangd = {
        setup = function(opts)
            local clangd = load_module 'clangd_extensions'
            if clangd then
                clangd.setup(opts)
            end
        end,
        args = {},
    },
    ['rust-analyzer'] = {
        setup = function(opts)
            local tools = load_module 'rust-tools'
            if tools then
                tools.setup(opts)
            end
        end,
        args = {},
    },
}

local function setup(ft)
    vim.validate { filetype = { ft, 'string' } }
    local cmp = load_module 'cmp'

    local server_idx = RELOAD('plugins.lsp.utils').check_language_server(ft)
    if server_idx then
        local server = RELOAD('plugins.lsp.servers')[ft][server_idx]
        local config = server.config or server.exec
        local init = vim.deepcopy(server.options) or {}
        init.on_attach = require('plugins.lsp.config').on_attach
        if cmp then
            local cmp_lsp = require 'cmp_nvim_lsp'
            local capabilities
            if cmp_lsp.default_capabilities then
                capabilities = cmp_lsp.default_capabilities()
            else
                capabilities = cmp_lsp.update_capabilities(vim.lsp.protocol.make_client_capabilities())
            end
            init.capabilities = vim.tbl_deep_extend('keep', init.capabilities or {}, capabilities)
        end
        if preload[config] and preload[config].setup then
            local opts = preload[config].args
            opts.server = init
            preload[config].setup(opts)
        else
            lsp[config].setup(init)
        end
        return true
    end
    return false
end

for filetype, _ in pairs(lsp_configs) do
    local has_server = setup(filetype)
    local null_config = null_configs[filetype]

    if not has_server and null_config then
        vim.list_extend(null_sources, null_config.servers)
    end
end

if null_ls and next(null_sources) ~= nil then
    null_ls.setup {
        sources = null_sources,
        debug = false,
        on_attach = function(client, bufnr)
            require('plugins.lsp.config').on_attach(client, bufnr, true)
        end,
    }
end

return {
    setup = setup,
}
