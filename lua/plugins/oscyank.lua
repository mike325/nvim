local executable =  require'utils.files'.executable

local set_command = require'neovim.commands'.set_command
local set_autocmd = require'neovim.autocmds'.set_autocmd
-- local set_mapping = require'neovim.mappings'.set_mapping

if vim.g.OSCTERM then
    vim.g.oscyank_term = vim.g.OSCTERM
elseif executable('kitty') then
    vim.g.oscyank_term = 'kitty'
elseif vim.env.TMUX then
    vim.g.oscyank_term = 'tmux'
else
    vim.g.oscyank_term = 'default'
end

set_command{
    lhs = 'OSCTerm',
    rhs = 'let g:oscyank_term = <q-args>',
    args = {force = true, nargs = 1, complete = 'customlist,neovim#vim_oscyank'}
}

set_autocmd{
    event = 'TextYankPost',
    pattern = '*',
    cmd = [[if v:event.operator is 'y' && (v:event.regname is '+' || v:event.regname is '*' || v:event.regname is '') | OSCYankReg + | endif]],
    group = 'OSCYank',
}
