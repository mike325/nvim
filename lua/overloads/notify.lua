local lsp_sign = 'DiagnosticSign'
local names = { 'error', 'hint', 'warn', 'info' }
local levels = { 'Error', 'Hint', 'Warn', 'Info' }

local hl_group = {}
for idx, level in ipairs(levels) do
    hl_group[names[idx]] = lsp_sign .. level
end

local notify_backend
local has_ui = #vim.api.nvim_list_uis() > 0
local function notify_format(msg, level, opts)
    if opts and opts.title then
        return ('[%s]: %s'):format(opts.title, msg)
    end
    return msg
end

if has_ui then
    local nvim_notify = vim.F.npcall(require, 'notify')

    if nvim_notify then
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
        notify_backend = nvim_notify
        vim.keymap.set('n', '<C-w>n', function()
            nvim_notify.dismiss { pending = true, silent = true }
        end, { noremap = true, silent = true })
    else
        local mini_notify = vim.F.npcall(require, 'mini.notify')
        if mini_notify then
            local nvim = require 'nvim'
            mini_notify.setup {}

            notify_backend = (function(f)
                return function(msg, level, opts)
                    local text = notify_format(msg, level, opts)
                    f(text, level, opts)
                end
            end)(mini_notify.make_notify())

            vim.keymap.set('n', '<C-w>n', function()
                mini_notify.clear()
            end, { noremap = true, silent = true })

            nvim.command.set('Notifications', function(opts)
                mini_notify.show_history()
            end, { nargs = 0, desc = 'Show all notifications' })
        else
            notify_backend = function(msg, level, opts)
                local notification = notify_format(msg, level, opts)
                local msg_hl = {
                    hl_group.hint,
                    hl_group.info,
                    hl_group.warn,
                    hl_group.error,
                    [0] = hl_group.error,
                    DEBUG = hl_group.hint,
                    ERROR = hl_group.error,
                    INFO = hl_group.info,
                    TRACE = hl_group.error,
                    WARN = hl_group.warn,
                    WARNING = hl_group.warn,
                }

                vim.api.nvim_echo({ { notification, level and msg_hl[level] or msg_hl.INFO } }, true, {})
            end
        end
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
            term_colors.purple,
            term_colors.green,
            term_colors.yellow,
            term_colors.red,
            [0] = term_colors.red,
            DEBUG = term_colors.purple,
            ERROR = term_colors.red,
            INFO = term_colors.green,
            TRACE = term_colors.red,
            WARN = term_colors.yellow,
            WARNING = term_colors.yellow,
        }

        local text = notify_format(msg, level, opts)

        local fd = (level and level == 'ERROR') and 2 or 1
        local output = ('%s\n'):format(text)
        local handle_type = vim.loop.guess_handle(fd)
        if handle_type == 'tty' then
            local stdio = vim.loop.new_tty(fd, false)
            if level and level ~= '' then
                output = ('%s%s%s\n'):format(level_colors[level] or level_colors.INFO, text, term_colors.reset_color)
            end
            stdio:write(output)
            stdio:close()
        elseif handle_type == 'file' then
            -- NOTE: Not using utils.files since they call notify for errors, making this recursive
            local stdio = assert(vim.loop.fs_open(('/proc/%s/fd/%s'):format(vim.fn.getpid(), fd), 'a+', 438))

            local ok, err, _ = vim.loop.fs_write(stdio, output, 0)
            if not ok then
                vim.print(err)
            end

            assert(vim.loop.fs_close(stdio))
        elseif handle_type == 'pipe' then
            -- TODO: Migrate this to libuv
            -- local stdio = vim.loop.new_pipe(false)
            -- assert(stdio:open(fd) == 0)
            -- stdio:write(output)
            -- stdio:close()
            if fd == 1 then
                io.stdout:write(output)
            else
                io.stderr:write(output)
            end
        else
            error(debug.traceback(('Unknown fd handle type: %s\n'):format(vim.loop.guess_handle(fd))))
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
        -- NOTE: Make sure to use the correct level value if we get an integer
        level = vim.log.levels[level] or level
    end
    notify_backend(msg, level, opts)
end

-- NOTE: Schedule notifications allow us to use them in thread's callbacks
vim.notify = function(msg, level, opts)
    if vim.is_thread() or vim.in_fast_event() then
        vim.schedule(function()
            notify(msg, level, opts)
        end)
    elseif not vim.g.no_output then
        notify(msg, level, opts)
    end
end
