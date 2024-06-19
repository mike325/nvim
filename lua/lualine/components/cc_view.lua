local M = require('lualine.component'):extend()

local statusline = require 'statusline'

function M:init(options)
    M.super.init(self, options)
end

function M:update_status()
    return statusline.clearcase.component()
end

return M
