local has_lsp_config = vim.version.ge(vim.version(), { 0, 11 })
local lsp_enable_group
if not has_lsp_config then
    lsp_enable_group = vim.api.nvim_create_augroup('LspEnableConfig', { clear = true })
end

-- NOTE: Python server usage priority
local python_servers = {
    'pylsp',
    'pylyzer',
    'basedpyright',
    'jedi_language_server',
}

-- These are the configs I'm intersted in, they can be defined with a empty dict
-- and resolved with vim.lsp.config
local configs = vim.api.nvim_get_runtime_file('after/lsp/*.lua', true)

--- Check if the server is available
---@param configname string
---@return string?
local function find_config(configname)
    return vim.iter(configs):find(function(c)
        return (vim.fs.basename(c):gsub('%.lua$', '')) == configname
    end)
end

--- Check if the server is available
---@param configname string
---@return boolean
local function has_server(configname)
    local config
    if has_lsp_config then
        config = vim.lsp.config[configname]
    else
        local configfile = find_config(configname)
        if configfile then
            config = dofile(configfile)
        end
    end
    if config and config.cmd then
        return vim.fn.executable(config.cmd[1]) == 1
    end
    return false
end

--- Enable lsp servers
---@param server string
local function enable_server(server)
    if has_lsp_config then
        vim.lsp.enable(server)
    else
        local configfile = find_config(server)
        if configfile then
            local config = dofile(configfile)
            local fts = config.filetypes

            vim.api.nvim_create_autocmd({ 'Filetype' }, {
                desc = 'Enable LSP config on filetypes',
                group = lsp_enable_group,
                pattern = table.concat(fts, ','),
                callback = function(args)
                    local root_dir = vim.uv.cwd()
                    if config.root_markers or config.root_dir then
                        local markers = config.root_markers --[[@as string|string[]|nil ]]
                            or config.root_dir --[[@as fun(name: string, path: string):boolean|nil]]
                        root_dir = vim.fs.root(args.buf, markers)
                    end
                    config.name = server
                    config.root_dir = root_dir
                    vim.lsp.start(config, { bufnr = args.buf })
                end,
            })
        end
    end
end

local confignames = vim.iter(configs):map(vim.fs.basename):map(require('utils.files').filename):totable()

vim.iter(confignames)
    :filter(function(config)
        return not vim.list_contains(python_servers, config) and has_server(config)
    end)
    :each(enable_server)

local python_configs = vim.iter(confignames)
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
