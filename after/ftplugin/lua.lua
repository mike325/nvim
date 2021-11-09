local sys = require 'sys'

local executable = require('utils.files').executable
local is_file = require('utils.files').is_file

-- vim.opt_local.expandtab = true
-- vim.opt_local.tabstop = 4
-- vim.opt_local.shiftwidth = 0
-- vim.opt_local.softtabstop = -1

vim.opt_local.includeexpr = [[substitute(v:fname,'\.','/','g')]]
vim.opt_local.define =
    [[^\s*\(local\s\+\)\?\(function\s\+\(\i\+[.:]\)\?\|\ze\i\+\s*=\s*\|\(\i\+[.:]\)\?\ze\s*=\s*\)]]

vim.opt_local.suffixesadd:prepend '.lua'
vim.opt_local.suffixesadd:prepend 'init.lua'
vim.opt_local.path:prepend(require('sys').base .. '/lua')

local luacheck_args = {
    '--max-cyclomatic-complexity',
    '20',
    '--std',
    'luajit',
    '--formatter',
    'plain',
    '--codes',
    '--ranges',
    '%',
}

if executable 'luacheck' then
    vim.opt_local.makeprg = 'luacheck ' .. table.concat(luacheck_args, ' ')
else
    local exe = {
        sys.home .. '/.luarocks/bin/luacheck',
        sys.home .. '/cache/nvim/packer_hererocks/' .. sys.luajit .. '/bin/luacheck',
    }
    for i = 1, #exe do
        if is_file(exe[i]) then
            vim.opt_local.makeprg = ('%s %s'):format(exe[i], table.concat(luacheck_args, ' '))
        end
    end
end

if vim.fn.executable 'stylua' == 1 then
    vim.opt_local.formatexpr = [[luaeval('RELOAD"filetypes.lua".format()')]]
end
