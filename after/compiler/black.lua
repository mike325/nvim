local set_compiler = RELOAD('utils.functions').set_compiler
set_compiler('black', {
    option = 'formatprg',
    configs = {
        'pyproject.toml',
    },
})
