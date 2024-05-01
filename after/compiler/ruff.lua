local set_compiler = RELOAD('utils.functions').set_compiler
set_compiler('ruff', {
    subcommand = 'check',
    configs = {
        'ruff.toml',
        '.ruff.toml',
        'pyproject.toml',
    },
})
