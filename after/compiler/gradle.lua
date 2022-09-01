local nvim = require 'neovim'
local has_cmd = nvim.has.command 'CompilerSet'

if not has_cmd then
    nvim.command.set('CompilerSet', function(command)
        vim.cmd(('setlocal %s'):format(command.args))
    end, { nargs = 1, buffer = true })
end

local cmd = {
    'gradle',
    '--quiet',
}

nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))
-- TODO: Need to find a way to set this with the default CompilerSet command
vim.bo.efm = table.concat(vim.opt_global.efm:get(), ',')

vim.b.current_compiler = 'gradle'

if not has_cmd then
    nvim.command.del('CompilerSet', true)
end
