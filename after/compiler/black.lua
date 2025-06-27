local name = 'black'
local compiler = RELOAD('utils.functions').get_compiler(name, {
    language = 'python',
    option = 'formatprg',
    config_flag = '--config',
    configs = {
        'pyproject.toml',
    },
})

vim.cmd.CompilerSet('makeprg=' .. compiler.makeprg)
if compiler.efm then
    vim.bo.errorformat = compiler.efm
end
vim.b.current_compiler = name
