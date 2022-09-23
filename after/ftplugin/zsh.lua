local sys = require 'sys'

local zfunction_dirs = {
    sys.home .. '/.config/shell/zfunctions',
    sys.home .. '/.zsh/zfunctions',
    sys.home .. '/.zsh',
    sys.home .. '/.config/shell',
}

vim.opt_local.path:append(zfunction_dirs)
