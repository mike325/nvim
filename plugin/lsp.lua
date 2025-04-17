if not vim.version.ge(vim.version(), { 0, 11 }) then
    return
end

local python_servers = {
    'pylsp',
    'pylyzer',
    'basedpyright',
    'jedi_language_server',
}

local function has_server(config)
    local cmd = dofile(config).cmd
    return vim.fn.executable(cmd[1]) == 1
end

local lsp_configs = 'after/lsp'
local configs = vim.api.nvim_get_runtime_file(('%s/*.lua'):format(lsp_configs), true)

local servers = vim.iter(configs)
    :filter(function(config)
        local fname = vim.fs.basename(config)
        return not vim.list_contains(python_servers, (fname:gsub('%.lua$', ''))) and has_server(config)
    end)
    :map(function(config)
        return (vim.fs.basename(config):gsub('%.lua$', ''))
    end):totable()
vim.lsp.enable(servers)

local python_configs = vim.iter(configs)
    :filter(function(config)
        local fname = vim.fs.basename(config)
        return vim.list_contains(python_servers, (fname:gsub('%.lua$', ''))) and has_server(config)
    end)
    :map(function(config)
        return (vim.fs.basename(config):gsub('%.lua$', ''))
    end):totable()

for server in vim.iter(python_servers) do
    if vim.list_contains(python_configs, server) then
        vim.lsp.enable(server)
        break
    end
end
