return {
    {
        'glacambre/firenvim',
        cond = function()
            local ssh = vim.env.SSH_CONNECTION or false
            local firenvim = vim.g.started_by_firenvim ~= nil
            return (not vim.g.minimal and not ssh) or firenvim
        end,
        config = function()
            if vim.g.started_by_firenvim ~= nil then
                vim.api.nvim_set_keymap('n', '<C-z>', '<cmd>call firenvim#hide_frame()<CR>', { noremap = true })
            end
        end,
        build = function()
            vim.fn['firenvim#install'](0)
        end,
    },
    {
        'phaazon/hop.nvim',
        cond = not vim.g.minimal,
        config = function()
            require 'configs.hop'
        end,
        event = 'VeryLazy',
    },
}
