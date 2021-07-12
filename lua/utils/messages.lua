local M = {}

function M.echoerr(msg)
    assert(
        (type(msg) == 'string' or (type(msg) == type({}) and vim.tbl_islist(msg))) and #msg > 0 ,
        debug.traceback('Invalid message: '..vim.inspect(msg))
    )
    if type(msg) == type('') then
        msg = {msg}
    end
    for i=1,#msg do
        msg[i] = {msg[i], 'ErrorMsg'}
    end
    vim.api.nvim_echo(
        msg,
        true,
        {}
    )
end

function M.echowarn(msg)
    assert(
        (type(msg) == 'string' or (type(msg) == type({}) and vim.tbl_islist(msg))) and #msg > 0 ,
        debug.traceback('Invalid message: '..vim.inspect(msg))
    )
    if type(msg) == type('') then
        msg = {msg}
    end
    for i=1,#msg do
        msg[i] = {msg[i], 'WarningMsg'}
    end
    vim.api.nvim_echo(
        msg,
        true,
        {}
    )
end

function M.echomsg(msg)
    assert(
        (type(msg) == 'string' or (type(msg) == type({}) and vim.tbl_islist(msg))) and #msg > 0 ,
        debug.traceback('Invalid message: '..vim.inspect(msg))
    )
    if type(msg) == type('') then
        msg = {msg}
    end
    vim.api.nvim_echo(
        {msg},
        true,
        {}
    )
end

return M
