local M = {}

local function echo(msg, title, cat)
    assert(
        (type(msg) == type('') or (type(msg) == type({}) and vim.tbl_islist(msg))) and #msg > 0 ,
        debug.traceback('Invalid message: '..vim.inspect(msg))
    )
    assert(
        title == nil or (type(title) == type('') and title ~= ''),
        debug.traceback('Invalid title: '..vim.inspect(title))
    )

    if type(msg) == type('') then
        msg = {msg}
    end

    if title then
        table.insert(msg, 1, ('[%s]: '):format(title))
    end

    local msg_hl = {
        error = 'ErrorMsg',
        warn  = 'WarningMsg',
        info  = 'LspDiagnosticsSignHint',
        debug = 'LspDiagnosticsSignInformation',
    }

    for i=1,#msg do
        msg[i] = {msg[i], msg_hl[cat]}
    end

    vim.api.nvim_echo(
        msg,
        true,
        {}
    )
end

function M.echoerr(msg, title)
    echo(msg, title, 'error')
end

function M.echowarn(msg, title)
    echo(msg, title, 'warn')
end

function M.echomsg(msg, title)
    echo(msg, title, 'info')
end

function M.echodebug(msg, title)
    echo(msg, title, 'debug')
end

return M
