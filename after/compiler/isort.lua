local set_compiler = RELOAD('utils.functions').set_compiler
set_compiler('isort', {
    language = 'python',
    option = 'formatprg',
})
