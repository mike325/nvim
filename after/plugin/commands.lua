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

local function stop_server(server, force)
    vim.iter(vim.lsp.get_clients { name = server }):map(function(client)
        client:stop(force)
    end)
    return true
end

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

--- @param opts Command.Opts
nvim.command.set('LspStart', function(opts)
    local name = opts.args
    local config = vim.lsp.config[name]
    vim.defer_fn(function()
        config.name = config.name or name
        vim.lsp.start(config, { bufnr = 0 })
    end, 1000)
end, {
    bang = true,
    nargs = 1,
    complete = completions.lsp_configs,
    desc = 'Start an lsp server in the current buffer',
})

--- @param opts Command.Opts
nvim.command.set('LspStop', function(opts)
    local server = opts.args
    if stop_server(server, opts.bang) then
        vim.notify(string.format('%s stopped', server), vim.log.levels.INFO, { title = 'LspStop' })
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
    vim.notify(string.format('Restartting %s', server), vim.log.levels.INFO, { title = 'LspRestart' })
    if stop_server(server) then
        vim.lsp.enable(server, true)
    end
end, {
    bang = true,
    nargs = 1,
    complete = completions.lsp_clients,
    desc = 'Restart an active lsp server',
})

-- TODO: Add support to change between local and osc/remote open
-- NOTE: Override Netrw command
nvim.command.set('Open', function(opts)
    local url = opts.args ~= '' and opts.args or vim.fn.expand '<cfile>'
    vim.ui.open(url)
end, {
    nargs = '?',
    complete = 'file',
    desc = 'Open file in the default OS external program',
})
