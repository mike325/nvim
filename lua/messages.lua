local get_icon = require('utils.functions').get_icon

local lsp_sign = 'DiagnosticSign'
local names = { 'error', 'hint', 'warn', 'info' }
local levels = { 'Error', 'Hint', 'Warn', 'Info' }

local hl_group = {}
for idx, level in ipairs(levels) do
    hl_group[names[idx]] = lsp_sign .. level
end

local has_notify, nvim_notify = pcall(require, 'notify')

if has_notify and vim.env.NO_COOL_FONTS then
    nvim_notify.setup {
        icons = {
            DEBUG = get_icon 'bug',
            ERROR = get_icon 'error',
            INFO = get_icon 'info',
            TRACE = '✎',
            WARN = get_icon 'warn',
        },
    }
end

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

    if has_notify then
        nvim_notify(msg, level, opts)
    else
        if opts and opts.title then
            msg = ('[%s]: %s'):format(opts.title, msg)
        end

        local msg_hl = {
            hl_group['error'],
            hl_group['warn'],
            hl_group['info'],
            hl_group['hint'],
            [0] = hl_group['error'],
            TRACE = hl_group['error'],
            ERROR = hl_group['error'],
            WARN = hl_group['warn'],
            WARNING = hl_group['warn'],
            INFO = hl_group['info'],
            DEBUG = hl_group['hint'],
        }

        vim.api.nvim_echo({ { msg, level and msg_hl[level] or msg_hl.INFO } }, true, {})
    end
end

-- NOTE: Schedule notifications allow us to use them in thread's callbacks
vim.notify = vim.schedule_wrap(notify)
