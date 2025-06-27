local sys = require 'sys'

local name = 'flake8'
local compiler = RELOAD('utils.functions').get_compiler(name, {
    language = 'python',
    config_flag = '--config',
    configs = {
        'tox.ini',
        '.flake8',
        'setup.cfg',
    },
    global_config = vim.fs.normalize(sys.name == 'windows' and '~/.flake8' or '~/.config/flake8'),
})

vim.cmd.CompilerSet('makeprg=' .. compiler.makeprg)
if compiler.efm then
    vim.bo.errorformat = compiler.efm
end
vim.b.current_compiler = name
