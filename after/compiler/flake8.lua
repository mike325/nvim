local nvim = require 'neovim'
local sys = require 'sys'
local is_file = require('utils.files').is_file
local pyignores = RELOAD('filetypes.python').pyignores

local cmd = { 'flake8' }

local global_settings = vim.fn.expand(sys.name == 'windows' and '~/.flake8' or '~/.config/flake8')

-- NOTE: flake8 does not support pyproject, hopefully in a near future
if
    not is_file(global_settings)
    and not is_file './tox.ini'
    and not is_file './.flake8'
    and not is_file './setup.cfg'
    -- and not is_file './setup.py'
    -- and not is_file './pyproject.toml'
then
    vim.list_extend(cmd, { '--max-line-length=120', '--ignore=' .. table.concat(pyignores, ',') })
end

table.insert(cmd, '%')

nvim.ex.CompilerSet('makeprg=' .. table.concat(cmd, '\\ '))

vim.b.current_compiler = 'flake8'
