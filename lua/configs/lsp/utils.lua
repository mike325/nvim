local sys = require 'sys'

local executable = require('utils.files').executable
local is_dir = require('utils.files').is_dir
local langservers = require 'configs.lsp.servers'
local config_file = 'lsp.json'

local M = {}

function M.get_cmd(server)
    local cmd
    if server.options and server.options.cmd then
        cmd = server.options.cmd
    elseif server.cmd then
        cmd = server.cmd
    elseif server.exec then
        cmd = server.exec
    end

    if cmd and type(cmd) ~= type {} then
        cmd = { cmd }
    end

    return cmd
end

function M.get_name(server)
    local name
    if server.config then
        name = server.config
    elseif server.exec then
        name = server.exec
    else
        name = M.get_cmd(server)[1]
    end
    return name
end

function M.get_root(server, ft)
    ft = ft or vim.bo.filetype

    local lang_markers = {
        python = {
            'pyproject.toml',
            'ruff.toml',
        },
        c = {
            'Makefile',
            'CMakeLists.txt',
            'compile_commands.json',
        },
    }
    lang_markers.cpp = lang_markers.c

    local markers = { '.git', '.svn' }

    if lang_markers[ft] then
        vim.list_extend(markers, lang_markers[ft])
    end
    if server.markers then
        vim.list_extend(markers, server.markers)
    end
    local root_dir = vim.fs.find(markers, { upward = true })[1]
    return root_dir and vim.fs.dirname(root_dir) or vim.uv.cwd()
end

function M.load_config_from_json(json_filename)
    local utils_io = RELOAD 'utils.files'
    json_filename = json_filename or vim.fs.find(config_file, { upward = true, type = 'file' })[1]
    if json_filename then
        local configs = utils_io.read_json(json_filename)
        if configs.languageserver then
            return configs.languageserver
        end
    end
    return false
end

function M.dump_config_to_json(ft, server)
    local utils_io = RELOAD 'utils.files'
    local configs = { langservers = {} }
    local json_filename = vim.fs.find(config_file, { upward = true, type = 'file' })[1]
    if json_filename then
        configs = utils_io.read_json(json_filename)
    end
    configs.langservers[ft] = server
    configs.langservers[ft].commands = nil
    utils_io.dump_json(config_file, configs)
end

function M.get_server_config(lang, name)
    vim.validate {
        lang = { lang, 'string' },
        name = { name, { 'string', 'number' }, true },
    }

    local function get_config_cmd(server)
        local tmp_server = vim.deepcopy(server)

        local configs = {
            ruff = { 'ruff.toml', 'pyproject.toml' },
            pylsp = { 'pyproject.toml' },
        }

        if configs[name] then
            local config = configs[name]
            local path = vim.fs.find(config, { upward = true, type = 'file' })[1]
            if path then
                local cmd
                if tmp_server.cmd then
                    cmd = tmp_server.cmd
                elseif (tmp_server.options or {}).cmd then
                    cmd = tmp_server.options.cmd
                else
                    cmd = { tmp_server.exec or tmp_server.config }
                    tmp_server.cmd = cmd
                end
                vim.list_extend(cmd, { '--config', path })
            end
        end
        return tmp_server
    end

    if langservers[lang] then
        if name then
            if type(name) == type '' then
                for _, server in ipairs(langservers[lang]) do
                    if server.exec == name or server.config == name then
                        return get_config_cmd(server)
                    end
                end
            else
                local server = langservers[lang][name]
                if server then
                    return get_config_cmd(server)
                end
            end
        else
            for _, server in ipairs(langservers[lang]) do
                local dir = is_dir(sys.cache .. '/lspconfig/' .. (server.config or server.exec))
                local exec = server.exec and executable(server.exec) or false
                if exec or dir then
                    return get_config_cmd(server)
                end
            end
        end
    end
    return false
end

function M.check_language_server(lang)
    vim.validate { lang = { lang, 'string' } }

    local utils_io = RELOAD 'utils.files'
    local json_filename = vim.fs.find(config_file, { upward = true, type = 'file' })[1]
    if json_filename then
        local config = utils_io.read_json(json_filename)
        if config.langservers and config.langservers[lang] then
            return config.langservers[lang]
        end
    end
    return M.get_server_config(lang)
end

function M.get_language_server_cmd(filetype)
    vim.validate { filetype = { filetype, 'string' } }
    local server = M.check_language_server(filetype)
    if not server then
        return {}
    end
    local exec
    if server.options and server.options.cmd then
        exec = server.options.cmd
    else
        exec = server.cmd or { server.exec }
    end
    return exec
end

function M.switch_source_header_splitcmd(bufnr, splitcmd)
    local method_name = 'textDocument/switchSourceHeader'
    splitcmd = splitcmd or 'edit'
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local lsp = vim.F.npcall(require, 'lspconfig')
    if lsp then
        bufnr = require('lspconfig').util.validate_bufnr(bufnr)
    end

    local params = vim.lsp.util.make_text_document_params(bufnr)
    local client = vim.lsp.get_clients { name = 'clangd', bufnr = bufnr }[1]
    if not client then
        return false
    end
    -- client.request(method_name, params, function(err, result) end, bufnr)
    local candidate = client.request_sync(method_name, params, 1000, bufnr)
    if not candidate or type(candidate) == type '' or candidate.err or not candidate.result then
        return false
    end
    vim.cmd { cmd = splitcmd, args = { vim.uri_to_fname(candidate.result) } }
    return true
end

function M.symbol_info()
    local method_name = 'textDocument/symbolInfo'

    local bufnr = vim.api.nvim_get_current_buf()
    local clangd_client = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
    if not clangd_client or not clangd_client.supports_method(method_name)  then
        return vim.notify('Clangd client not found', vim.log.levels.ERROR)
    end
    local win = vim.api.nvim_get_current_win()
    local params = vim.lsp.util.make_position_params(win, clangd_client.offset_encoding)
    clangd_client.request(method_name, params, function(err, res)
        if err or #res == 0 then
            -- Clangd always returns an error, there is not reason to parse it
            return
        end
        local container = string.format('container: %s', res[1].containerName) ---@type string
        local name = string.format('name: %s', res[1].name) ---@type string
        vim.lsp.util.open_floating_preview({ name, container }, '', {
            height = 2,
            width = math.max(string.len(name), string.len(container)),
            focusable = false,
            focus = false,
            border = 'single',
            title = 'Symbol Info',
        })
    end, bufnr)
end

function M.check_null_format(client)
    local null_ls = vim.F.npcall(require, 'null-ls')
    if null_ls and client.name ~= 'null-ls' then
        local null_configs = require 'configs.lsp.null'

        local ft = vim.bo.filetype
        local has_formatting = client.server_capabilities.documentFormattingProvider
            or client.server_capabilities.documentRangeFormattingProvider

        if not has_formatting and null_ls and null_configs[ft] and null_configs[ft].formatter then
            if not null_ls.is_registered(null_configs[ft].formatter.name) then
                null_ls.register { null_configs[ft].formatter }
            end
        end
    end
end

function M.check_null_diagnostics(client)
    local extra_linters = {
        lua_ls = true,
    }
    if extra_linters[client.name] then
        local null_ls = vim.F.npcall(require, 'null-ls')
        if null_ls and client.name ~= 'null-ls' then
            local null_configs = require 'configs.lsp.null'

            local ft = vim.bo.filetype
            if null_ls and null_configs[ft] and null_configs[ft].linter then
                if not null_ls.is_registered(null_configs[ft].linter.name) then
                    null_ls.register { null_configs[ft].linter }
                end
            end
        end
    end
end

function M.is_null_ls_formatting_enabled(bufnr)
    local null_ls = vim.F.npcall(require, 'null-ls')
    if not null_ls then
        return false
    end
    local ft = vim.bo[bufnr].filetype
    local generators = require('null-ls.generators').get_available(ft, require('null-ls.methods').internal.FORMATTING)
    return #generators > 0
end

return M
