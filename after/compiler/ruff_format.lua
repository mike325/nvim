local set_compiler = RELOAD('utils.functions').set_compiler
set_compiler('ruff', {
    subcommand = 'format',
    option = 'formatprg',
    configs = {
        'ruff.toml',
        '.ruff.toml',
        'pyproject.toml',
    },
})
