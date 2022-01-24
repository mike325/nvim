local ft = vim.opt_local.filetype:get()
require('utils.buffers').setup(ft, {
    define = [[^\(\(function\s\+\)\?\ze\i\+()\|\s*\(local\s\+\)\?\ze\k\+=.*\)]],
})
