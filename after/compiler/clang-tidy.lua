local name = 'clang-tidy'
local compiler = RELOAD('utils.functions').get_compiler(name, { language = 'cpp' })

vim.cmd.CompilerSet('makeprg=' .. compiler.makeprg)
if compiler.efm then
    vim.bo.errorformat = compiler.efm
end
vim.b.current_compiler = name
