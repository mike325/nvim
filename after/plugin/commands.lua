local nvim = require 'nvim'
local completions = RELOAD 'completions'

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

local function stop_server(server)
    if server ~= '' then
        local id, _ = server:match '^(%d):(.+)'
        if tonumber(id) then
            vim.lsp.stop_client(tonumber(id) --[[@as number]])
            return true
        end
    end
    vim.notify(string.format('Cannot stop server: "%s"', server), vim.log.levels.ERROR)
    return false
end

--- @param opts Command.Opts
nvim.command.set('LspStop', function(opts)
    local server = opts.args
    if stop_server(server) then
        local _, name = server:match '^(%d):(.+)'
        vim.notify(string.format('%s stopped', name), vim.log.levels.INFO, { title = 'LspStop' })
    end
end, {
    bang = true,
    nargs = 1,
    complete = completions.lsp_clients,
    desc = 'Stop an active lsp server',
})

--- @param opts Command.Opts
nvim.command.set('LspRestart', function(opts)
    local server = opts.args
    local id, name = server:match '^(%d):(.+)'
    local config = vim.lsp.config[name]
    if tonumber(id) then
        config = vim.lsp.get_clients { id = tonumber(id) }
    end

    vim.notify(string.format('Restartting %s', server), vim.log.levels.INFO, { title = 'LspRestart' })
    if stop_server(server) then
        vim.defer_fn(function()
            config.name = config.name or name
            vim.lsp.start(config, { bufnr = 0 })
        end, 1000)
    end
end, {
    bang = true,
    nargs = 1,
    complete = completions.lsp_clients,
    desc = 'Restart an active lsp server',
})


if not nvim.plugins['nvim-lspconfig'] then
    nvim.command.set('LspInfo', function()
        vim.cmd.checkhealth 'vim.lsp'
    end, {
        nargs = 0,
        desc = 'Open LSP info',
    })

    nvim.command.set('LspLog', function()
        vim.cmd.edit(vim.lsp.get_log_path())
    end, {
        nargs = 0,
        desc = 'Open LSP log',
    })
else
    pcall(require, 'lspconfig')
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
