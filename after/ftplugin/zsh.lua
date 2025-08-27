local sys = require 'sys'

local zfunction_dirs = {
    sys.home .. '/.config/shell/zfunctions',
    sys.home .. '/.zsh/zfunctions',
    sys.home .. '/.zsh',
    sys.home .. '/.config/shell',
}

vim.opt_local.path:append(zfunction_dirs)
vim.opt_local.path:append(vim.split(vim.env.PATH, ':', { trimempty = true }))

local ft = vim.bo.filetype
require('utils.buffers').setup(ft, {
    define = [[^\(\(function\s\+\)\?\ze\i\+()\|\s*\(local\s\+\)\?\ze\k\+=.*\)]],
})
