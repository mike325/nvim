local set_compiler = RELOAD('utils.functions').set_compiler
local executable = require('utils.files').executable

local cmd = {}
if executable 'java' and require('utils.files').is_file(vim.fn.stdpath 'state' .. '/utils/plantuml.jar') then
    local jar_path = vim.fn.stdpath 'state' .. '/utils/plantuml.jar'
    vim.list_extend(cmd, { 'java', '-jar', jar_path })
else
    table.insert(cmd, 'plantuml')
end

set_compiler(cmd, { language = 'plantuml' })
