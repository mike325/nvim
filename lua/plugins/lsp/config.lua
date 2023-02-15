local nvim = require 'neovim'

local has_telescope, _ = pcall(require, 'telescope')
-- local servers = require 'plugins.lsp.servers'

local builtin
if has_telescope then
    builtin = require 'telescope.builtin'
end

local null_ls = vim.F.npcall(require, 'null-ls')
local null_configs = require 'plugins.lsp.null'

local M = {}

M.commands = {
    Type = { vim.lsp.buf.type_definition },
    Declaration = { vim.lsp.buf.declaration },
    OutgoingCalls = { vim.lsp.buf.outgoing_calls },
    IncommingCalls = { vim.lsp.buf.incoming_calls },
    Implementation = { vim.lsp.buf.implementation },
    Format = {
        function()
            RELOAD('utils.buffers').format()
        end,
    },
    RangeFormat = {
        function()
            RELOAD('utils.buffers').format()
        end,
    },
    Rename = {
        function()
            vim.lsp.buf.rename {}
        end,
    },
    Signature = {
        function()
            vim.lsp.buf.signature_help {}
        end,
    },
    Hover = {
        function()
            vim.lsp.buf.hover {}
        end,
    },
    Definition = {
        function()
            if has_telescope then
                builtin.lsp_definitions()
            else
                vim.lsp.buf.definition()
            end
        end,
    },
    References = {
        function()
            if has_telescope then
                builtin.lsp_references()
            else
                vim.lsp.buf.references()
            end
        end,
    },
    -- Diagnostics = {
    --     function()
    --         if has_telescope then
    --             builtin.diagnostics()
    --         else
    --             vim.diagnostic.setloclist()
    --         end
    --     end,
    -- },
    DocSymbols = {
        function()
            if has_telescope then
                builtin.lsp_document_symbols()
            else
                vim.lsp.buf.document_symbol()
            end
        end,
    },
    WorkSymbols = {
        function()
            if has_telescope then
                builtin.lsp_workspace_symbols()
            else
                vim.lsp.buf.workspace_symbol()
            end
        end,
    },
    CodeAction = {
        function()
            vim.lsp.buf.lsp_code_actions()
        end,
    },
}

function M.lsp_mappings(client, bufnr)
    vim.validate {
        client = { client, 'table' },
        bufnr = { bufnr, 'number', true },
    }

    bufnr = bufnr or nvim.get_current_buf()
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'

    local mappings = {
        ['gd'] = {
            capability = 'declarationProvider',
            mapping = function()
                vim.lsp.buf.declaration()
            end,
        },
        ['gi'] = {
            capability = 'implementationProvider',
            mapping = function()
                vim.lsp.buf.implementation()
            end,
        },
        ['gr'] = {
            capability = 'referencesProvider',
            mapping = function()
                if has_telescope then
                    require('telescope.builtin').lsp_references()
                else
                    vim.lsp.buf.references()
                end
            end,
        },
        ['K'] = {
            capability = 'hoverProvider',
            mapping = function()
                vim.lsp.buf.hover()
            end,
        },
        ['<leader>r'] = {
            capability = 'renameProvider',
            mapping = function()
                vim.lsp.buf.rename()
            end,
        },
        ['ga'] = {
            capability = 'codeActionProvider',
            mapping = function()
                vim.lsp.buf.code_action()
            end,
        },
        ['gh'] = {
            capability = 'signatureHelpProvider',
            mapping = function()
                vim.lsp.buf.signature_help()
            end,
        },
        ['<leader>s'] = {
            mapping = function()
                if has_telescope then
                    require('telescope.builtin').lsp_document_symbols()
                else
                    vim.lsp.buf.document_symbol {}
                end
            end,
        },
        -- ['<space>wa'] = '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
        -- ['<space>wr'] = '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
        -- ['<space>wl'] = '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
        -- ['<leader>D'] = '<cmd>lua vim.lsp.buf.type_definition()<CR>',
    }

    -- TODO: Move this config to lsp/server.lua
    if client.name == 'sumneko_lua' then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end

    for mapping, val in pairs(mappings) do
        if not val.capability or client.server_capabilities[val.capability] then
            vim.keymap.set('n', mapping, val.mapping, { silent = true, buffer = bufnr, noremap = true })
        end
    end

    for command, values in pairs(M.commands) do
        if type(values[1]) == 'function' then
            local opts = { buffer = true }
            vim.tbl_extend('keep', opts, values[2] or {})
            nvim.command.set(command, values[1], opts)
        end
    end
end

function M.on_attach(client, bufnr, is_null)
    vim.validate {
        client = { client, 'table' },
        bufnr = { bufnr, 'number', true },
        is_null = { is_null, 'boolean', true },
    }

    local ft = vim.bo.filetype
    local has_formatting = client.server_capabilities.documentFormattingProvider
        or client.server_capabilities.documentRangeFormattingProvider

    if not has_formatting and null_ls and null_configs[ft] and null_configs[ft].formatter then
        -- TODO: Does this needs the custom "on_attach" handler?
        if not null_ls.is_registered(null_configs[ft].formatter.name) then
            if vim.opt_local.formatexpr:get() == '' then
                vim.opt_local.formatexpr = ([[luaeval('require"utils.buffers".format("%s")')]]):format(ft)
            end
            null_ls.register { null_configs[ft].formatter }
        end
    end
end

return M
