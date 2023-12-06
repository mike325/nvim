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

local lsp = vim.F.npcall(require, 'lspconfig')

if not lsp then
    return false
end

local lsp_configs = require 'configs.lsp.servers'
local nvim = require 'nvim'
local executable = require('utils.files').executable

local preload = {
    clangd = {
        setup = function(init)
            local clangd = vim.F.npcall(require, 'clangd_extensions')
            if clangd then
                clangd.setup { server = init }
            else
                lsp.clangd.setup(init)
            end
        end,
    },
    ['rust-analyzer'] = {
        setup = function(init)
            local tools = vim.F.npcall(require, 'rust-tools')
            if tools then
                tools.setup { server = init }
            else
                lsp.rust_analyzer.setup(init)
            end
        end,
    },
}

local settedup_configs = {}
local function setup(ft)
    vim.validate { filetype = { ft, 'string' } }

    local server_idx = RELOAD('configs.lsp.utils').check_language_server(ft)
    if server_idx then
        local server = RELOAD('configs.lsp.servers')[ft][server_idx]
        local config = server.config or server.exec
        if not settedup_configs[config] then
            settedup_configs[config] = true
            local init = vim.deepcopy(server.options) or {}
            init.cmd = init.cmd or server.cmd
            local capabilities = vim.lsp.protocol.make_client_capabilities()
            if vim.F.npcall(require, 'cmp') then
                local cmp_lsp = vim.F.npcall(require, 'cmp_nvim_lsp')
                if cmp_lsp then
                    capabilities = vim.tbl_deep_extend('force', capabilities, cmp_lsp.default_capabilities())
                end
            end
            init.capabilities = vim.tbl_deep_extend('keep', init.capabilities or {}, capabilities or {})
            if preload[config] then
                preload[config].setup(init)
            else
                lsp[config].setup(init)
            end
        end
        return true
    end
    return false
end

local null_sources = {}
local null_ls = vim.F.npcall(require, 'null-ls')
local null_configs = require 'configs.lsp.null'

if null_ls then
    table.insert(null_sources, null_ls.builtins.code_actions.gitsigns)
end

for filetype, _ in pairs(lsp_configs) do
    local has_server = setup(filetype)
    local null_config = null_configs[filetype]

    if not has_server and null_config then
        vim.list_extend(null_sources, null_config.servers)
    end
end

if executable 'jq' then
    local null_config = null_configs.json
    vim.list_extend(null_sources, null_config.servers)
end

if null_ls and next(null_sources) ~= nil then
    null_ls.setup {
        sources = null_sources,
        debug = false,
    }
end

return {
    setup = setup,
}
