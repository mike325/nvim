local nvim = require 'nvim'

nvim.command.set('Make', function(opts)
    RELOAD('filetypes.make.utils').execute(opts.fargs)
end, { nargs = '*', desc = 'Wrapper around make binary' })
