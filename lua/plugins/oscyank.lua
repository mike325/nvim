-- NOTE: Since we already have utils.strings.base64_(encode/decode) we may no longer need this plugin
local nvim = require 'nvim'

if vim.env.TMUX then
    vim.g.oscyank_osc52 = '\x1bPtmux;\x1b]52;c;%s\x07\x1b\\'
end

nvim.autocmd.OSCYank = {
    event = 'TextYankPost',
    pattern = '*',
    callback = function(args)
        if vim.v.event.operator == 'y' and (vim.v.register == '+' or vim.v.register == '*' or vim.v.register == '') then
            vim.fn.OSCYank(nvim.reg[vim.v.register])
        end
    end,
}
