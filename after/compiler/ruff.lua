local set_compiler = RELOAD('utils.functions').set_compiler
set_compiler('ruff', {
    configs = {
        'pyproject.toml',
        'ruff.toml',
        '.ruff.toml',
    },
})
