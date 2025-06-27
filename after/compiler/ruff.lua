local name = 'ruff'
local compiler = RELOAD('utils.functions').get_compiler(name, {
    language = 'python',
    subcommand = 'check',
    config_flag = '--config',
    configs = {
        'ruff.toml',
        '.ruff.toml',
        'pyproject.toml',
    },
})

vim.cmd.CompilerSet('makeprg=' .. compiler.makeprg)
if compiler.efm then
    vim.bo.errorformat = compiler.efm
end
vim.b.current_compiler = name
