return {
    {
        'glacambre/firenvim',
        cond = function()
            local ssh = vim.env.SSH_CONNECTION or false
            local firenvim = vim.g.started_by_firenvim ~= nil
            return (not vim.g.minimal and not ssh and not vim.g.vscode) or firenvim
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
