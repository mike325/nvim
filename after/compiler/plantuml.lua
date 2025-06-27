local executable = require('utils.files').executable

local cmd = {}
if executable 'java' and require('utils.files').is_file(vim.fn.stdpath 'state' .. '/utils/plantuml.jar') then
    local jar_path = vim.fn.stdpath 'state' .. '/utils/plantuml.jar'
    vim.list_extend(cmd, { 'java', '-jar', jar_path })
else
    table.insert(cmd, 'plantuml')
end

local compiler = RELOAD('utils.functions').get_compiler(cmd, { language = 'plantuml' })

vim.cmd.CompilerSet('makeprg=' .. compiler.makeprg)
if compiler.efm then
    vim.bo.errorformat = compiler.efm
end
vim.b.current_compiler = 'plantuml'
