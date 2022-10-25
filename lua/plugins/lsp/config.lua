-- local sys = require 'sys'
local nvim = require 'neovim'

local load_module = require('utils.functions').load_module

local lsp = load_module 'lspconfig'

if lsp == nil then
    return false
end

local has_telescope, _ = pcall(require, 'telescope')
-- local servers = require 'plugins.lsp.servers'

local builtin
if has_telescope then
    builtin = require 'telescope.builtin'
end

local null_ls = load_module 'null-ls'
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
    Diagnostics = {
        function()
            if has_telescope then
                builtin.diagnostics()
            else
                vim.diagnostic.setloclist()
            end
        end,
    },
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

function M.on_attach(client, bufnr, is_null)
    vim.validate {
        client = { client, 'table' },
        bufnr = { bufnr, 'number', true },
        is_null = { is_null, 'boolean', true },
    }

    local ft = vim.bo.filetype

    bufnr = bufnr or nvim.get_current_buf()
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

    local lua_cmd = '<cmd>lua %s<CR>'

    local mappings = {
        ['gd'] = {
            capability = 'declarationProvider',
            mapping = lua_cmd:format 'vim.lsp.buf.declaration()',
        },
        ['gi'] = {
            capability = 'implementationProvider',
            mapping = lua_cmd:format 'vim.lsp.buf.implementation()',
        },
        ['gr'] = {
            capability = 'referencesProvider',
            mapping = lua_cmd:format(
                (has_telescope and "require'telescope.builtin'.lsp_references()") or 'vim.lsp.buf.references()'
            ),
        },
        ['K'] = {
            capability = 'hoverProvider',
            mapping = lua_cmd:format 'vim.lsp.buf.hover()',
        },
        ['<leader>r'] = {
            capability = 'renameProvider',
            mapping = lua_cmd:format 'vim.lsp.buf.rename()',
        },
        ['ga'] = {
            capability = 'codeActionProvider',
            mapping = lua_cmd:format 'vim.lsp.buf.code_action()',
        },
        ['gh'] = {
            capability = 'signatureHelpProvider',
            mapping = lua_cmd:format 'vim.lsp.buf.signature_help()',
        },
        ['=L'] = {
            mapping = lua_cmd:format 'vim.diagnostic.setloclist()',
        },
        ['<leader>s'] = {
            mapping = lua_cmd:format(
                (has_telescope and "require'telescope.builtin'.lsp_document_symbols()")
                    or 'vim.lsp.buf.document_symbol{}'
            ),
        },
        ['=d'] = {
            mapping = lua_cmd:format 'vim.diagnostic.open_float()',
        },
        [']d'] = {
            mapping = lua_cmd:format 'vim.diagnostic.goto_next{wrap=false}',
        },
        ['[d'] = {
            mapping = lua_cmd:format 'vim.diagnostic.goto_prev{wrap=false}',
        },
        -- ['<space>wa'] = '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
        -- ['<space>wr'] = '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
        -- ['<space>wl'] = '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
        -- ['<leader>D'] = '<cmd>lua vim.lsp.buf.type_definition()<CR>',
    }

    for mapping, val in pairs(mappings) do
        if not val.capability or client.server_capabilities[val.capability] then
            vim.keymap.set('n', mapping, val.mapping, { silent = true, buffer = bufnr, noremap = true })
        end
    end

    local has_formatting = client.server_capabilities.documentFormattingProvider
        or client.server_capabilities.documentRangeFormattingProvider

    -- Disable neomake for lsp buffers
    if nvim.plugins.neomake then
        pcall(vim.fn['neomake#CancelJobs'], 0)
        pcall(vim.fn['neomake#cmd#clean'], 1)
        pcall(vim.cmd, 'silent call neomake#cmd#disable(b:)')
    end

    if is_null then
        for command, values in pairs(M.commands) do
            if type(values[1]) == 'function' then
                nvim.command.set(command, values[1], { buffer = true })
            end
        end
    elseif not has_formatting and null_ls and null_configs[ft] and null_configs[ft].formatter then
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
