local ft = vim.bo.filetype
require('utils.buffers').setup(ft, {
    define = [[^\(\(function\s\+\)\?\ze\i\+()\|\s*\(local\s\+\)\?\ze\k\+=.*\)]],
})

vim.opt_local.path:append(vim.split(vim.env.PATH, ':', { trimempty = true }))
