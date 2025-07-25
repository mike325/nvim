-- local executable = require('utils.files').executable

local M = {
    -- makeprg = {},
    -- formatprg = {
    --     -- jq = {
    --     --     '-s',
    --     -- },
    -- },
}

function M.get_formatter(stdin)
    return false
end

function M.get_linter()
    return false
end

return M
