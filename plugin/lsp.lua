if not vim.version.ge(vim.version(), { 0, 11 }) then
    return
end

local python_servers = {
    'pylsp',
    'pylyzer',
    'basedpyright',
    'jedi_language_server',
}

local function has_server(config_name)
    local config = vim.lsp.config[config_name]
    if config and config.cmd then
        return vim.fn.executable(config.cmd[1]) == 1
    end
    return false
end

local lsp_configs = 'after/lsp'
local configs = vim.iter(vim.api.nvim_get_runtime_file(('%s/*.lua'):format(lsp_configs), true)):map(function(config)
    return (vim.fs.basename(config):gsub('%.lua$', ''))
end)

local servers = configs
    :filter(function(config)
        return not vim.list_contains(python_servers, config) and has_server(config)
    end)
    :totable()
vim.lsp.enable(servers)

local python_configs = configs
    :filter(function(config)
        return vim.list_contains(python_servers, config) and has_server(config)
    end)
    :totable()

for server in vim.iter(python_servers) do
    if vim.list_contains(python_configs, server) then
        vim.lsp.enable(server)
        break
    end
end
