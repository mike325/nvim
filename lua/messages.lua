local function notify(msg, level, opts)
    vim.validate {
        message = { msg, 'string' },
        level = {
            level,
            function(l)
                return not l or type(l) == type '' or type(l) == type(1)
            end,
            'string or integer log level',
        },
        options = {
            opts,
            function(o)
                return not o or (type(o) == type {} and not vim.tbl_islist(o))
            end,
            'table of options',
        },
    }

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
