local trouble = vim.F.npcall(require, 'trouble')

if trouble == nil then
    return false
end

local nvim = require 'nvim'
local get_icon = require('utils.ui').get_icon

trouble.setup {
    position = 'bottom',
    height = 10,
    width = 50,
    mode = 'document_diagnostics', -- "lsp_workspace_diagnostics", "quickfix", "lsp_references", "loclist"
    auto_close = true,
    icons = true,
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

vim.keymap.set('n', '=T', function()
    local document_diagnostics = vim.diagnostic and vim.diagnostic.get(0) or vim.lsp.diagnostic.get(0)
    local lsp_workspace_diagnostics = vim.diagnostic and vim.diagnostic.get() or vim.lsp.diagnostic.get_all()
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
        if vim.bo[buf].filetype == 'Trouble' then
            trouble_open = true
            vim.cmd.TroubleClose()
            break
        end
    end
    if not trouble_open then
        if #document_diagnostics > 0 then
            vim.cmd.Trouble 'document_diagnostics'
        elseif has_workspace_diagnostics then
            vim.cmd.Trouble 'lsp_workspace_diagnostics'
        elseif #loc_diagnostics > 0 then
            vim.cmd.Trouble 'loclist'
        elseif #qf_diagnostics > 0 then
            vim.cmd.Trouble 'quickfix'
        else
            vim.notify('Nothing to check !', vim.log.levels.WARN, { title = 'Trouble' })
        end
    end
end, { noremap = true, silent = true, desc = 'Trouble mapping to toggle diagnostics' })

return true
