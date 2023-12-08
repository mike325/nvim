local set_compiler = RELOAD('utils.functions').set_compiler
set_compiler('ruff', {
    subcommand = 'format',
    option = 'formatprg',
    configs = {
        'pyproject.toml',
        'ruff.toml',
        '.ruff.toml',
    },
})
