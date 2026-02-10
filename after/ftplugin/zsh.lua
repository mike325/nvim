local sys = require 'sys'

local zfunction_dirs = {
    vim.fs.joinpath(sys.home, '.config', 'shell'),
    vim.fs.joinpath(sys.home, '.zsh'),
}

vim.opt_local.path:append(zfunction_dirs)
vim.iter(zfunction_dirs):each(function(zdir)
    vim.opt_local.path:append(vim.fs.joinpath(zdir, 'zfunctions'))
end)
vim.opt_local.path:append(vim.split(vim.env.PATH, ':', { trimempty = true }))

local ft = vim.bo.filetype
require('utils.buffers').setup(ft, {
    define = [[^\(\(function\s\+\)\?\ze\i\+()\|\s*\(local\s\+\)\?\ze\k\+=.*\)]],
})
