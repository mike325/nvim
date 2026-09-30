local executable = require('utils.files').executable

local M = {
    makeprg = {},
    formatprg = {},
}

function M.get_formatter(stdin)
    return false
end

function M.get_linter()
    return false
end

function M.get_render()
    local cmd
    if executable 'java' and require('utils.files').is_file(vim.fn.stdpath 'state' .. '/utils/plantuml.jar') then
        local jar_path = vim.fn.stdpath 'state' .. '/utils/plantuml.jar'
        cmd = { 'java', '-jar', jar_path }
    elseif executable 'plantuml' then
        cmd = { 'plantuml' }
    end
    return cmd
end

return M
