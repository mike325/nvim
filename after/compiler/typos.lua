local name = 'typos'
local compiler = RELOAD('utils.functions').get_compiler(name, { args = { '--format', 'brief' } })

vim.cmd.CompilerSet('makeprg=' .. compiler.makeprg)
if compiler.efm then
    vim.bo.errorformat = compiler.efm
end
vim.b.current_compiler = name
