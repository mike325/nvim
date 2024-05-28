local ft = vim.bo.filetype
require('utils.buffers').setup(ft, {
    define = [[^\(\(function\s\+\)\?\ze\i\+()\|\s*\(local\s\+\)\?\ze\k\+=.*\)]],
})
