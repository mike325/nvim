local nvim = require 'nvim'

local has_telescope, _ = pcall(require, 'telescope')
-- local servers = require 'plugins.lsp.servers'

local builtin
if has_telescope then
    builtin = require 'telescope.builtin'
end

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
    if vim.bo[bufnr].tagfunc == '' then
        vim.bo[bufnr].tagfunc = 'v:lua.vim.lsp.tagfunc'
    end

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
    if client.name == 'sumneko_lua' or client.name == 'lua_ls' then
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
    end

    -- NOTE: use HelpNeovim defined in after/ftplugin
    if vim.opt_local.filetype:get() == 'lua' then
        client.server_capabilities.hoverProvider = false
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

function M.is_null_ls_formatting_enabled(bufnr)
    local null_ls = vim.F.npcall(require, 'null-ls')
    if not null_ls then
        return false
    end
    local ft = vim.api.nvim_buf_get_option(bufnr, 'filetype')
    local generators = require('null-ls.generators').get_available(ft, require('null-ls.methods').internal.FORMATTING)
    return #generators > 0
end

return M
