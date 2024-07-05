local set_compiler = RELOAD('utils.functions').set_compiler
local sys = require 'sys'

set_compiler('flake8', {
    language = 'python',
    config_flag = '--config',
    configs = {
        'tox.ini',
        '.flake8',
        'setup.cfg',
    },
    global_config = vim.fs.normalize(sys.name == 'windows' and '~/.flake8' or '~/.config/flake8'),
})
