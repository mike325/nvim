local load_module = require('utils.helpers').load_module
local get_icon = require('utils.helpers').get_icon
-- local plugins = require'neovim'.plugins

local lsp = load_module 'lspconfig'

if lsp == nil then
    return false
end

local has_6 = vim.fn.has 'nvim-0.6' == 1
local diagnostic = vim.diagnostic or vim.lsp.diagnostic

local lsp_sign = has_6 and 'DiagnosticSign' or 'LspDiagnosticsSign'
local levels = { 'Error', 'Hint' }
local diagnostic_config = {
    signs = true,
    underline = true,
    update_in_insert = false,
    virtual_text = {
        spacing = 2,
        prefix = '❯',
    },
}

if has_6 then
    vim.list_extend(levels, { 'Warn', 'Info' })
    vim.diagnostic.config(diagnostic_config)
else
    vim.list_extend(levels, { 'Warning', 'Information' })
    vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
        diagnostic_config
    )
end

for _, level in pairs(levels) do
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

local original_set_virtual_text = diagnostic.set_virtual_text
local set_virtual_text_custom = function(lsp_diagnostics, bufnr, client_id, sign_ns, opts)
    opts = opts or {}
    -- show all messages that are Warning and above (Warning, Error)
    opts.severity_limit = 'Error'
    original_set_virtual_text(lsp_diagnostics, bufnr, client_id, sign_ns, opts)
end
diagnostic.set_virtual_text = set_virtual_text_custom

local lsp_configs = require 'plugins.lsp.servers'
local lsp_setup = require('plugins.lsp.utils').setup

for filetype, _ in pairs(lsp_configs) do
    lsp_setup(filetype)
end

return {
    setup = lsp_setup,
}
