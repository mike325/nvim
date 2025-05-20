local nvim = require 'nvim'

-- TODO: Lazy check for mini
local has_mini = nvim.plugins['mini.nvim'] ~= nil or (vim.g.minimal and vim.F.npcall(require, 'mini.git') ~= nil)

if not has_mini and not nvim.plugins['vim-fugitive'] then
    nvim.command.set('Git', function(opts) end, { bang = true, nargs = '*' })

    nvim.command.set('Gwrite', function(opts)
        local filename = (not opts.args or opts.args == '') and vim.api.nvim_buf_get_name(0) or opts.args
        if filename == '' or filename:match '^%w+://' then
            return
        end

        local cwd = vim.pesc(vim.uv.cwd() .. '/')
        filename = (filename:gsub('^' .. cwd, ''))

        vim.cmd.write { filename, bang = opts.bang }
        require('utils.git').exec.add(filename)
    end, { bang = true, nargs = '?', complete = 'file' })
end

-- TODO: Add support to change between local and osc/remote open
-- NOTE: Override Netrw command
nvim.command.set('Open', function(opts)
    vim.ui.open(opts.args)
end, {
    nargs = 1,
    complete = 'file',
    desc = 'Open file in the default OS external program',
})

if not nvim.plugins['nvim-lspconfig'] then
    local completions = RELOAD 'completions'

    nvim.command.set('LSPInfo', function()
        vim.cmd.checkhealth 'vim.lsp'
    end, {
        nargs = 0,
        desc = 'Open LSP info',
    })

    nvim.command.set('LSPStop', function(opts)
        local server = opts.args
        if server ~= '' then
            local id, name = server:match '^(%d):(.+)'
            if tonumber(id) then
                vim.notify(string.format('Stopping %s', name), vim.log.levels.INFO, { title = 'LSPStop' })
                vim.lsp.stop_client(tonumber(id) --[[@as number]])
            end
        end
    end, {
        bang = true,
        nargs = 1,
        complete = completions.lsp_clients,
        desc = 'Stop an active lsp server',
    })

    nvim.command.set('LSPRestart', function(opts)
        local server = opts.args
        if server ~= '' then
            local id, name = server:match '^(%d):(.+)'
            if tonumber(id) then
                vim.notify(string.format('Restartting %s', name), vim.log.levels.INFO, { title = 'LSPStop' })
                vim.lsp.stop_client(tonumber(id) --[[@as number]])
                local config = vim.lsp.config[name]
                if config then
                    vim.defer_fn(function()
                        vim.lsp.start(config)
                    end, 1000)
                else
                    vim.notify(
                        'Cannot restart ' .. name .. ', cannot retrieve config',
                        vim.log.levels.ERROR,
                        { title = 'LSPRestart' }
                    )
                end
            end
        end
    end, {
        bang = true,
        nargs = 1,
        complete = completions.lsp_clients,
        desc = 'Restart an active lsp server',
    })
end
