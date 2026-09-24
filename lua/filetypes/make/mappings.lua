vim.api.nvim_create_user_command('Make', function(opts)
    RELOAD('filetypes.make.utils').execute(opts.fargs)
end, { nargs = '*', bang = true, desc = 'Wrapper around make binary' })
