local M = {}

function M.echoerr(msg)
    assert(type(msg) == 'string' and #msg > 0, 'Invalid message: '..vim.inspect(msg))
    vim.api.nvim_err_writeln(msg)
end

function M.echowarn(msg)
    assert(type(msg) == 'string' and #msg > 0, 'Invalid message: '..vim.inspect(msg))
    vim.api.nvim_echo({{msg, 'WarningMsg'}}, true, {})
end

return M
