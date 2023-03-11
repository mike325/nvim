-- luacheck: max line length 143
local executable = require('utils.files').executable

local nvim = require 'nvim'

if vim.g.OSCTERM then
    vim.g.oscyank_term = vim.g.OSCTERM
elseif vim.env.OSCTERM then
    vim.g.oscyank_term = vim.env.OSCTERM
elseif executable 'kitty' then
    vim.g.oscyank_term = 'kitty'
elseif vim.env.TMUX then
    vim.g.oscyank_term = 'tmux'
else
    vim.g.oscyank_term = 'default'
end

nvim.command.set('OSCTerm', 'let g:oscyank_term = <q-args>', { nargs = 1, complete = RELOAD('completions').oscyank })

nvim.autocmd.OSCYank = {
    event = 'TextYankPost',
    pattern = '*',
    callback = function(args)
        if vim.v.event.operator == 'y' and (vim.v.register == '+' or vim.v.register == '*' or vim.v.register == '') then
            vim.fn.OSCYank(nvim.reg[vim.v.register])
        end
    end,
}
