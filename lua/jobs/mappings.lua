local nvim = require 'neovim'

nvim.command.set('KillJob', function(opts)
    RELOAD('mappings').kill_job(opts)
end, { nargs = '?', bang = true })

vim.keymap.set('n', '=p', function()
    RELOAD('mappings').toggle_progress_win()
end, { noremap = true, silent = true })
