local set_compiler = RELOAD('utils.functions').set_compiler
set_compiler('ruff', {
    language = 'python',
    -- subcommand = 'check',
    config_flag = '--config',
    configs = {
        'ruff.toml',
        '.ruff.toml',
        'pyproject.toml',
    },
})
