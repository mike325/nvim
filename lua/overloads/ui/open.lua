vim.ui.open = (function(overridden)
    return function(path)
        vim.validate { path = { path, 'string' } }
        if path:match '^https?://.+' and vim.env.SSH_CONNECTION then
            require('utils.functions').send_osc52('open', '"' .. path .. '"')
            return {
                code = 0,
                signal = 0,
                stderr = '',
                stdout = '',
            },
                nil
        end
        return overridden(path)
    end
end)(vim.ui.open)
