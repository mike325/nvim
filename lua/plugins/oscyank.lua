-- luacheck: max line length 143
local executable = require('utils.files').executable

local nvim = require 'neovim'
local set_autocmd = require('neovim.autocmds').set_autocmd

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

nvim.command.set('OSCTerm', 'let g:oscyank_term = <q-args>', { nargs = 1, complete = _completions.oscyank })

set_autocmd {
    event = 'TextYankPost',
    pattern = '*',
    cmd = [[call neovim#copy_yanked_text()]],
    group = 'OSCYank',
}
