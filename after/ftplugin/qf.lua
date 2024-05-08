if not vim.g.loaded_cfilter then
    vim.cmd.packadd { args = { 'cfilter' }, bang = false }
    vim.g.loaded_cfilter = true
end
