-- local executable = require('utils.files').executable

local M = {
    -- makeprg = {
    --     xmllint = {},
    -- },
    -- formatprg = {
    --     xmllint = {
    --         '--format',
    --     },
    -- },
}

function M.get_formatter(stdin)
    return false
end

function M.get_linter()
    return false
end

return M
