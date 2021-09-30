local function notify(msg, level, opts)
    assert(type(msg) == type '', debug.traceback('Invalid message: ' .. vim.inspect(msg)))
    assert(
        level == nil or type(level) == type '' or type(level) == type(0),
        debug.traceback('Invalid log level: ' .. vim.inspect(level))
    )
    assert(
        opts == nil or (type(opts) == type {} and not vim.tbl_islist(opts)),
        debug.traceback('Invalid opts: ' .. vim.inspect(opts))
    )

    if level and type(level) == type '' then
        level = level:upper()
    end

    -- if vim.opt.verbose:get() == 1 then
    -- end

    local has_notify, floating_notify = pcall(require, 'notify')

    if has_notify then
        floating_notify(msg, level, opts)
    else
        if opts and opts.title then
            msg = ('[%s]: %s'):format(opts.title, msg)
        end

        local msg_hl = {
            'ErrorMsg',
            'WarningMsg',
            'LspDiagnosticsSignHint',
            'LspDiagnosticsSignInformation',
            [0] = 'ErrorMsg',
            TRACE = 'ErrorMsg',
            ERROR = 'ErrorMsg',
            WARN = 'WarningMsg',
            WARNING = 'WarningMsg',
            INFO = 'LspDiagnosticsSignHint',
            DEBUG = 'LspDiagnosticsSignInformation',
        }

        vim.api.nvim_echo({ { msg, level and msg_hl[level] or msg_hl.INFO } }, true, {})
    end
end

vim.notify = notify
