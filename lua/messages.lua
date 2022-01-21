local nvim = require 'neovim'

local has_nvim_6 = nvim.has { 0, 6 }

local lsp_sign = has_nvim_6 and 'DiagnosticSign' or 'LspDiagnosticsSign'
local names = { 'error', 'hint', 'warn', 'info' }
local levels = { 'Error', 'Hint' }
if has_nvim_6 then
    vim.list_extend(levels, { 'Warn', 'Info' })
else
    vim.list_extend(levels, { 'Warning', 'Information' })
end

local hl_group = {}
for idx, level in ipairs(levels) do
    hl_group[names[idx]] = lsp_sign .. level
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

    local has_notify, floating_notify = pcall(require, 'notify')

    if has_notify then
        floating_notify(msg, level, opts)
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

vim.notify = notify
