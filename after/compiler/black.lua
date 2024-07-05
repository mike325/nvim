local set_compiler = RELOAD('utils.functions').set_compiler
set_compiler('black', {
    language = 'python',
    option = 'formatprg',
    config_flag = '--config',
    configs = {
        'pyproject.toml',
    },
})
