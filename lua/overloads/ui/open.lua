if not vim.ui.open then
    vim.ui.open = function(uri)
        vim.validate {
            uri = { uri, 'string' },
        }
        local is_uri = uri:match '%w+:'
        if not is_uri then
            uri = vim.fn.expand(uri)
        end

        local cmd

        if vim.fn.has 'mac' == 1 then
            cmd = { 'open', uri }
        elseif vim.fn.has 'win32' == 1 then
            if vim.fn.executable 'powershell' == 1 then
                cmd = {
                    'powershell',
                    '-NoLogo',
                    '-NoProfile',
                    '-ExecutionPolicy',
                    'RemoteSigned',
                    '-Command',
                    'ii ' .. uri,
                }
            elseif vim.fn.executable 'rundll32' == 1 then
                cmd = { 'rundll32', 'url.dll,FileProtocolHandler', uri }
            else
                return nil, 'vim.ui.open: rundll32 not found'
            end
        elseif vim.fn.executable 'wslview' == 1 then
            cmd = { 'wslview', uri }
        elseif vim.fn.executable 'xdg-open' == 1 then
            cmd = { 'xdg-open', uri }
        else
            return nil, 'vim.ui.open: no handler found (tried: open, wslview, xdg-open and powershell)'
        end

        local output = vim.fn.system(cmd)
        if vim.v.shell_error ~= 0 then
            local msg = ('vim.ui.open: command failed (%d): %s'):format(vim.v.shell_error, vim.inspect(output))
            return {
                code = vim.v.shell_error,
                signal = 0,
                stderr = output,
                stdout = '',
            },
                msg
        end

        return {
            code = 0,
            signal = 0,
            stderr = '',
            stdout = output,
        },
            nil
    end
end

vim.ui.open = (function(overridden)
    return function(path)
        vim.validate { path = { path, 'string' } }
        if path:match '^https?://.+' and vim.env.SSH_CONNECTION then
            require('utils.functions').send_osc1337('open', '"' .. path .. '"')
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
