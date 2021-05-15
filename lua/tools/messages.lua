local M = {}

function M.echoerr(msg)
    assert(
        (type(msg) == 'string' or (type(msg) == type({}) and vim.tbl_islist(msg))) and #msg > 0 ,
        'Invalid message: '..vim.inspect(msg)
    )
    if type(msg) == type('') then
        msg = {msg}
    end
    msg[#msg + 1] = 'ErrorMsg'
    vim.api.nvim_echo(
        {msg},
        true,
        {}
    )
end

function M.echowarn(msg)
    assert(
        (type(msg) == 'string' or (type(msg) == type({}) and vim.tbl_islist(msg))) and #msg > 0 ,
        'Invalid message: '..vim.inspect(msg)
    )
    if type(msg) == type('') then
        msg = {msg}
    end
    msg[#msg + 1] = 'WarningMsg'
    vim.api.nvim_echo(
        {msg},
        true,
        {}
    )
end

function M.echomsg(msg)
    assert(
        (type(msg) == 'string' or (type(msg) == type({}) and vim.tbl_islist(msg))) and #msg > 0 ,
        'Invalid message: '..vim.inspect(msg)
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
