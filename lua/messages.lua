local lsp_sign = 'DiagnosticSign'
local names = { 'error', 'hint', 'warn', 'info' }
local levels = { 'Error', 'Hint', 'Warn', 'Info' }

local hl_group = {}
for idx, level in ipairs(levels) do
    hl_group[names[idx]] = lsp_sign .. level
end

local has_notify, nvim_notify = pcall(require, 'notify')

if has_notify then
    local get_icon = require('utils.functions').get_icon
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

local notify_backend
local has_ui = #vim.api.nvim_list_uis() > 0
if has_notify and has_ui then
    notify_backend = nvim_notify
elseif has_ui then
    notify_backend = function(msg, level, opts)
        if opts and opts.title then
            msg = ('[%s]: %s'):format(opts.title, msg)
        end

        local msg_hl = {
            hl_group.error,
            hl_group.warn,
            hl_group.info,
            hl_group.hint,
            [0] = hl_group.error,
            TRACE = hl_group.error,
            ERROR = hl_group.error,
            WARN = hl_group.warn,
            WARNING = hl_group.warn,
            INFO = hl_group.info,
            DEBUG = hl_group.hint,
        }

        vim.api.nvim_echo({ { msg, level and msg_hl[level] or msg_hl.INFO } }, true, {})
    end
else
    notify_backend = function(msg, level, opts)
        local term_colors = {
            black = '\27[30m',
            red = '\27[31m',
            green = '\27[32m',
            yellow = '\27[33m',
            blue = '\27[34m',
            purple = '\27[35m',
            cyan = '\27[36m',
            white = '\27[37m',
            orange = '\27[91m',
            normal = '\27[0m',
            reset_color = '\27[39m',
        }

        local level_colors = {
            TRACE = term_colors.red,
            ERROR = term_colors.red,
            WARN = term_colors.yellow,
            WARNING = term_colors.yellow,
            INFO = term_colors.green,
            DEBUG = term_colors.purple,
        }

        if opts and opts.title then
            msg = ('[%s]: %s'):format(opts.title, msg)
        end

        -- TODO: This cannot be redirected `1>/dev/null`, add support for pipes/redirects
        local stdout = vim.loop.new_tty(1, false)
        local stderr = vim.loop.new_tty(2, false)
        if level and level == 'ERROR' then
            local output = ('%s%s%s\n'):format(level_colors[level] or level_colors.INFO, msg, term_colors.reset_color)
            stderr:write(output)
        else
            local output
            if level and level ~= '' then
                output = ('%s%s%s\n'):format(
                    level_colors[level] or level_colors.INFO,
                    msg,
                    term_colors.reset_color
                )
            else
                output = ('%s\n'):format(msg)
            end
            stdout:write(output)
        end
    end
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
    notify_backend(msg, level, opts)
end

-- NOTE: Schedule notifications allow us to use them in thread's callbacks
vim.notify = function(msg, level, opts)
    if vim.is_thread() then
        vim.schedule(function()
            notify(msg, level, opts)
        end)
    else
        notify(msg, level, opts)
    end
end
