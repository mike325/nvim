local has_lsp_config = vim.version.ge(vim.version(), { 0, 11 })
local lsp_enable_group
if not has_lsp_config then
    lsp_enable_group = vim.api.nvim_create_augroup('LspEnableConfig', { clear = true })
end

local lsp_configs = 'after/lsp'

local python_servers = {
    'pylsp',
    'pylyzer',
    'basedpyright',
    'jedi_language_server',
}

-- These are the configs I'm intersted in, they can be defined with a empty dict
-- and resolved with vim.lsp.config
local configs = vim.iter(vim.api.nvim_get_runtime_file(('%s/*.lua'):format(lsp_configs), true))
    :map(function(config)
        return (vim.fs.basename(config):gsub('%.lua$', ''))
    end)
    :totable()

--- Check if the server is available
---@param config_name string
---@return boolean
local function has_server(config_name)
    local config
    if not has_lsp_config then
        local configfile = vim.iter(vim.api.nvim_get_runtime_file(('%s/*.lua'):format(lsp_configs), true))
            :find(function(c)
                return (vim.fs.basename(c):gsub('%.lua$', '')) == config_name
            end)
        if configfile then
            config = dofile(configfile)
        end
    else
        config = vim.lsp.config[config_name]
    end
    if config and config.cmd then
        return vim.fn.executable(config.cmd[1]) == 1
    end
    return false
end

--- Enable lsp servers
---@param servers string[]|string
local function enable_server(servers)
    if has_lsp_config then
        vim.lsp.enable(servers)
    else
        servers = type(servers) == type {} and servers or { servers }
        vim.iter(configs):each(function(configfile)
            local configname = (vim.fs.basename(configfile):gsub('%.lua$', ''))
            if vim.list_contains(servers, configname) then
                local config = dofile(configfile)
                local fts = config.filetypes

                vim.api.nvim_create_autocmd({ 'Filetype' }, {
                    desc = 'Enable LSP config on filetypes',
                    group = lsp_enable_group,
                    pattern = table.concat(fts, ','),
                    callback = function(args)
                        local root_dir = vim.uv.cwd()
                        if config.root_markers or config.root_dir then
                            root_dir = vim.fs.root(args.buf, config.root_markers or config.root_dir)
                        end
                        config.name = configname
                        config.root_dir = root_dir
                        vim.lsp.start(config, { bufnr = args.buf })
                    end,
                })
            end
        end)
    end
end

local servers = vim.iter(configs)
    :filter(function(config)
        return not vim.list_contains(python_servers, config) and has_server(config)
    end)
    :totable()
enable_server(servers)

local python_configs = vim.iter(configs)
    :filter(function(config)
        return vim.list_contains(python_servers, config) and has_server(config)
    end)
    :totable()

for server in vim.iter(python_servers) do
    if vim.list_contains(python_configs, server) then
        enable_server(server)
        break
    end
end
