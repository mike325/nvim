local echoerr = require'utils.messages'.echoerr

local download_packer = function()
    if vim.fn.input 'Download Packer? (y for yes)' ~= 'y' then
        return
    end

    local directory = string.format('%s/site/pack/packer/start/', string.gsub(vim.fn.stdpath'data', '\\', '/'))
    vim.fn.mkdir(directory, 'p')

    local out = vim.fn.system(
        string.format(
            'git clone %s %s',
            'https://github.com/wbthomason/packer.nvim', directory .. '/packer.nvim'
        )
    )

    print(out)
    print'Downloading packer.nvim...'
    if vim.v.shell_error == 0 then
        vim.cmd[[packadd packer.nvim]]
        return true
    end

    echoerr('Failed to download packer!! exit code: '..vim.v.shell_error)
    return false
end

return function()
    if not pcall(require, 'packer') then
        return download_packer()
    end
    return false
end
