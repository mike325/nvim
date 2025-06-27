local name = 'pre-commit'
local efm = RELOAD('mappings').precommit_efm
local compiler = RELOAD('utils.functions').get_compiler(name, { efm = efm })

vim.cmd.CompilerSet('makeprg=' .. compiler.makeprg)
if compiler.efm then
    vim.bo.errorformat = compiler.efm
end
vim.b.current_compiler = name
