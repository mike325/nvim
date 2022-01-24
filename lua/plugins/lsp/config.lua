-- local sys = require 'sys'
local nvim = require 'neovim'

local load_module = require('utils.helpers').load_module
-- local executable = require('utils.files').executable
-- local is_dir = require('utils.files').is_dir
-- local plugins = require'neovim'.plugins

-- local set_autocmd = require'neovim.autocmds'.set_autocmd
local set_command = require('neovim.commands').set_command

local lsp = load_module 'lspconfig'

if lsp == nil then
    return false
end

local show_diagnostics = true
local has_nvim_6 = nvim.has { 0, 6 }
local diagnostic = has_nvim_6 and vim.diagnostic or vim.lsp.diagnostic

local has_telescope, _ = pcall(require, 'telescope')
-- local servers = require 'plugins.lsp.servers'

local builtin = require 'telescope.builtin'
local themes = require 'telescope.themes'

local M = {}

M.commands = {
    Type = { vim.lsp.buf.type_definition },
    Declaration = { vim.lsp.buf.declaration },
    OutgoingCalls = { vim.lsp.buf.outgoing_calls },
    IncommingCalls = { vim.lsp.buf.incoming_calls },
    Implementation = { vim.lsp.buf.implementation },
    Format = {
        function()
            vim.lsp.buf.formatting()
        end,
    },
    RangeFormat = {
        function()
            vim.lsp.buf.range_formatting()
        end,
    },
    LSPToggleDiagnostics = {
        function()
            show_diagnostics = not show_diagnostics
            local diagnostic_config = {
                update_in_insert = false,
                underline = show_diagnostics,
                signs = show_diagnostics,
                virtual_text = show_diagnostics and {
                    spacing = 2,
                    prefix = '❯',
                } or false,
            }
            if has_nvim_6 then
                vim.diagnostic.config = diagnostic_config
            else
                _G['vim'].lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
                    vim.lsp.diagnostic.on_publish_diagnostics,
                    diagnostic_config
                )
            end
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
                builtin.lsp_definitions(themes.get_cursor {})
            else
                vim.lsp.buf.definition()
            end
        end,
    },
    References = {
        function()
            if has_telescope then
                builtin.lsp_references(themes.get_cursor {})
            else
                vim.lsp.buf.references()
            end
        end,
    },
    Diagnostics = {
        function()
            if has_telescope then
                local diagnostics_func = has_nvim_6 and 'diagnostics' or 'lsp_document_diagnostics'
                builtin[diagnostics_func](themes.get_dropdown {})
            else
                local loclist = has_nvim_6 and 'setloclist' or 'set_loclist'
                diagnostic[loclist]()
            end
        end,
    },
    DocSymbols = {
        function()
            if has_telescope then
                builtin.lsp_document_symbols(themes.get_dropdown {})
            else
                vim.lsp.buf.document_symbol()
            end
        end,
    },
    WorkSymbols = {
        function()
            if has_telescope then
                builtin.lsp_workspace_symbols(themes.get_dropdown {})
            else
                vim.lsp.buf.workspace_symbol()
            end
        end,
    },
    CodeAction = {
        function()
            if has_telescope then
                builtin.lsp_code_actions(themes.get_cursor {})
            else
                vim.lsp.buf.lsp_code_actions()
            end
        end,
    },
}

function M.on_attach(client, bufnr, is_null)
    vim.validate {
        client = { client, 'table' },
        bufnr = { bufnr, 'number', true },
        is_null = { is_null, 'boolean', true },
    }

    vim.bo.omnifunc = 'v:lua.vim.lsp.omnifunc'
    bufnr = bufnr or nvim.get_current_buf()
    local lua_cmd = '<cmd>lua %s<CR>'

    local diag_str = has_nvim_6 and 'vim.diagnostic' or 'vim.lsp.diagnostic'

    local mappings = {
        ['<C-]>'] = {
            capability = 'goto_definition',
            mapping = lua_cmd:format(
                (
                        has_telescope
                        and "require'telescope.builtin'.lsp_definitions(require'telescope.themes'.get_cursor{})"
                    ) or 'vim.lsp.buf.definition()'
            ),
        },
        ['gd'] = {
            capability = 'declaration',
            mapping = lua_cmd:format 'vim.lsp.buf.declaration()',
        },
        ['gi'] = {
            capability = 'implementation',
            mapping = lua_cmd:format 'vim.lsp.buf.implementation()',
        },
        ['gr'] = {
            capability = 'find_references',
            mapping = lua_cmd:format(
                (
                        has_telescope
                        and "require'telescope.builtin'.lsp_references(require'telescope.themes'.get_cursor{})"
                    ) or 'vim.lsp.buf.references()'
            ),
        },
        ['K'] = {
            capability = 'hover',
            mapping = lua_cmd:format 'vim.lsp.buf.hover()',
        },
        ['<leader>r'] = {
            capability = 'rename',
            mapping = lua_cmd:format 'vim.lsp.buf.rename()',
        },
        ['ga'] = {
            capability = 'code_action',
            mapping = lua_cmd:format(
                (
                        has_telescope
                        and "require'telescope.builtin'.lsp_code_actions(require'telescope.themes'.get_cursor{})"
                    ) or 'vim.lsp.buf.code_action()'
            ),
        },
        ['gh'] = {
            capability = 'signature_help',
            mapping = lua_cmd:format 'vim.lsp.buf.signature_help()',
        },
        ['=L'] = {
            mapping = lua_cmd:format(diag_str .. (has_nvim_6 and '.setloclist()' or '.set_loclist()')),
        },
        ['<leader>s'] = {
            mapping = lua_cmd:format(
                (
                        has_telescope
                        and "require'telescope.builtin'.lsp_document_symbols(require'telescope.themes'.get_dropdown{})"
                    ) or 'vim.lsp.buf.document_symbol{}'
            ),
        },
        ['=d'] = {
            mapping = lua_cmd:format(
                diag_str .. (has_nvim_6 and '.open_float()' or '.show_line_diagnostics()')
            ),
        },
        [']d'] = {
            mapping = lua_cmd:format(diag_str .. '.goto_next{wrap=false}'),
        },
        ['[d'] = {
            mapping = lua_cmd:format(diag_str .. '.goto_prev{wrap=false}'),
        },
        -- ['<space>wa'] = '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>',
        -- ['<space>wr'] = '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>',
        -- ['<space>wl'] = '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>',
        -- ['<leader>D'] = '<cmd>lua vim.lsp.buf.type_definition()<CR>',
    }

    for mapping, val in pairs(mappings) do
        if not val.capability or client.resolved_capabilities[val.capability] then
            vim.keymap.set('n', mapping, val.mapping, { silent = true, buffer = bufnr, noremap = true })
        end
    end

    if client.resolved_capabilities.document_formatting then
        vim.keymap.set('n', '=F', vim.lsp.buf.formatting, { silent = true, buffer = bufnr, noremap = true })
    end

    if client.resolved_capabilities.document_range_formatting then
        vim.keymap.set(
            'n',
            'gq',
            '<cmd>set opfunc=neovim#lsp_format<CR>g@',
            { silent = true, buffer = bufnr, noremap = true }
        )

        vim.keymap.set(
            'v',
            'gq',
            ':<C-U>call neovim#lsp_format(visualmode(), v:true)<CR>',
            { silent = true, buffer = bufnr, noremap = true }
        )
    end

    -- Disable neomake for lsp buffers
    if require('neovim').plugins.neomake then
        pcall(vim.fn['neomake#CancelJobs'], 0)
        pcall(vim.fn['neomake#cmd#clean'], 1)
        pcall(vim.cmd, 'silent call neomake#cmd#disable(b:)')
    end

    if is_null then
        for command, values in pairs(M.commands) do
            if type(values[1]) == 'function' then
                set_command {
                    lhs = command,
                    rhs = values[1],
                    args = { force = true, buffer = true },
                }
            end
        end
    end
end

return M
