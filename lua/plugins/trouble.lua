local load_module = require('utils.helpers').load_module
local trouble = load_module 'trouble'

if trouble == nil then
    return false
end

local nvim = require 'neovim'
local get_icon = require('utils.helpers').get_icon
local has_devicon = pcall(require, 'nvim-web-devicons')
local set_mapping = require('neovim.mappings').set_mapping

trouble.setup {
    position = 'bottom',
    height = 10,
    width = 50,
    mode = 'lsp_document_diagnostics', -- "lsp_workspace_diagnostics", "quickfix", "lsp_references", "loclist"
    auto_close = true,
    icons = has_devicon,
    use_lsp_diagnostic_signs = false,
    signs = {
        error = get_icon 'error',
        warning = get_icon 'warn',
        hint = get_icon 'hint',
        information = get_icon 'info',
        other = '﫠',
    },
    action_keys = {
        toggle_fold = { 'zA', 'za', '=' },
    },
}

set_mapping {
    mode = 'n',
    lhs = '=t',
    rhs = function()
        local lsp_document_diagnostics = vim.lsp.diagnostic.get(nvim.get_current_buf())
        local lsp_workspace_diagnostics = vim.lsp.diagnostic.get_all()
        local has_workspace_diagnostics = false
        for _, diagnostics in pairs(lsp_workspace_diagnostics) do
            if #diagnostics > 0 then
                has_workspace_diagnostics = true
                break
            end
        end
        local loc_diagnostics = vim.fn.getloclist(nvim.get_current_win())
        local qf_diagnostics = vim.fn.getqflist()
        local trouble_open = false
        for _, win in pairs(nvim.tab.list_wins(0)) do
            local buf = nvim.win.get_buf(win)
            if nvim.buf.get_option(buf, 'filetype') == 'Trouble' then
                trouble_open = true
                nvim.ex.TroubleClose()
                break
            end
        end
        if not trouble_open then
            if #lsp_document_diagnostics > 0 then
                vim.notify('Document Diagnostics', 'INFO', { title = 'Trouble' })
                nvim.ex.Trouble 'lsp_document_diagnostics'
            elseif has_workspace_diagnostics then
                vim.notify('Workspace Diagnostics', 'INFO', { title = 'Trouble' })
                nvim.ex.Trouble 'lsp_workspace_diagnostics'
            elseif #loc_diagnostics > 0 then
                vim.notify('Location list', 'INFO', { title = 'Trouble' })
                nvim.ex.Trouble 'loclist'
            elseif #qf_diagnostics > 0 then
                vim.notify('Quicfix', 'INFO', { title = 'Trouble' })
                nvim.ex.Trouble 'quickfix'
            else
                vim.notify('Nothing to check !', 'WARN', { title = 'Trouble' })
            end
        end
    end,
    args = { noremap = true, silent = true },
}

return true
