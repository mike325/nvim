local M = require('lualine.component'):extend()
local username = require('sys').username

function M:init(options)
    M.super.init(self, options)
end

function M:update_status()
    if vim.env.CLEARCASE_CMDLINE then
        local pattern = '^' .. username .. '_at_'
        if vim.env.CLEARCASE_CMDLINE:match(pattern) then
            return ' ' .. vim.split(vim.env.CLEARCASE_CMDLINE, ' ')[2]:gsub(pattern, '')
        end
        return ' ' .. vim.split(vim.env.CLEARCASE_CMDLINE, ' ')[2]
    end
    return ''
end

return M
