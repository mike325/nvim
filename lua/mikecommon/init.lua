local nvim = require('mikecommon/nvim')

local function init()
    vim.api.nvim_set_option('inccommand', 'split')
    vim.api.nvim_set_var('terminal_scrollback_buffer_size', 100000)

    if nvim.has_version('0.2') then
        vim.api.nvim_set_option('signcolumn', 'auto')
    end

    local ok, _ = pcall(vim.api.nvim_get_var, 'gonvim_running')
    if ok then
        vim.api.nvim_set_option('showmode', false)
        vim.api.nvim_set_option('ruler', false)
    else
        vim.api.nvim_set_option('titlestring', '%t (%f)')
        vim.api.nvim_set_option('title', true)
    end

    -- if nvim.has_version('0.5') and nvimFuncWrapper('tools#CheckLanguageServer') then
    --     nvimFuncWrapper('nvim#lsp')
    -- end

    if vim.loop.os_getenv('SSH_CONNECTION') == nil then
        vim.api.nvim_set_option('clipboard', 'unnamedplus,unnamed')
    end

end

return init()
