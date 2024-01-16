local download_lazy = function()
    local lazy_root = (vim.fn.stdpath 'data') .. '/lazy'
    local lazypath = lazy_root .. '/lazy.nvim'

    if vim.loop.fs_stat(lazypath) then
        vim.opt.rtp:prepend(lazypath)
        return true
    end

    if vim.fn.input 'Download lazy? (y for yes): ' ~= 'y' then
        return false
    end

    vim.fn.mkdir(lazy_root, 'p')
    vim.notify('Downloading lazy.nvim...', vim.log.levels.INFO, { title = 'Lazy Setup' })
    local out = vim.fn.system {
        'git',
        'clone',
        '--filter=blob:none',
        'https://github.com/folke/lazy.nvim.git',
        '--branch=stable', -- latest stable release
        lazypath,
    }

    if vim.v.shell_error == 0 then
        vim.notify(out or 'Lazy downloaded in: ' .. lazypath, vim.log.levels.INFO, { title = 'Lazy setup!' })
        vim.opt.rtp:prepend(lazypath)
        return true
    end
    vim.notify(
        'Failed to download lazy!! exit code: ' .. vim.v.shell_error,
        vim.log.levels.ERROR,
        { title = 'Lazy Setup' }
    )
    return false
end

return function()
    if not pcall(require, 'lazy') then
        return download_lazy()
    end
    return false
end
