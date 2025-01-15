local sys = require 'sys'

local executable = require('utils.files').executable
local is_dir = require('utils.files').is_dir
local langservers = require 'configs.lsp.servers'

local M = {}

local function check_lsp(servers)
    if type(servers) ~= type {} then
        servers = { servers }
    end
    for idx, server in pairs(servers) do
        local dir = is_dir(sys.cache .. '/lspconfig/' .. (server.config or server.exec))
        local exec = server.exec and executable(server.exec) or false
        if exec or dir then
            return idx
        end
    end

    return false
end

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

function M.get_server_config(lang, name)
    vim.validate {
        lang = { lang, 'string' },
        name = { name, { 'string', 'number' } },
    }

    local configs = {
        ruff = { 'ruff.toml', 'pyproject.toml' },
        pylsp = { 'pyproject.toml' },
    }

    if langservers[lang] then
        if type(name) == type '' then
            for _, server in ipairs(langservers[lang]) do
                if server.exec == name or server.config == name then
                    if configs[name] then
                        local config = configs[name]
                        local path = vim.fs.find(config, { upward = true, type = 'file' })[1]
                        if path then
                            if not server.cmd then
                                server.cmd = { server.exec or server.config }
                            end
                            vim.list_extend(server.cmd, { '--config', path })
                        end
                    end
                    return server
                end
            end
        else
            return langservers[lang][name] or false
        end
    end
    return false
end

function M.check_language_server(lang)
    vim.validate { lang = { lang, 'string' } }
    if langservers[lang] then
        return check_lsp(langservers[lang])
    end
    return false
end

function M.get_language_server_cmd(filetype)
    vim.validate { filetype = { filetype, 'string' } }
    local server_idx = M.check_language_server(filetype)
    if not server_idx then
        return {}
    end

    local server = langservers[filetype][server_idx]
    local exec
    if server.options and server.options.cmd then
        exec = server.options.cmd
    else
        exec = server.cmd or { server.exec }
    end
    return exec
end

function M.switch_source_header_splitcmd(bufnr, splitcmd)
    local lsp = vim.F.npcall(require, 'lspconfig')
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    if lsp then
        bufnr = require('lspconfig').util.validate_bufnr(bufnr)
    end
    local params = { uri = vim.uri_from_bufnr(bufnr) }
    local clients = vim.lsp.get_clients { name = 'clangd', bufnr = bufnr }
    local server = clients[1]
    if not server then
        return false
    end
    local candidate = server.request_sync('textDocument/switchSourceHeader', params, 1000, bufnr)
    if not candidate or type(candidate) == type '' or candidate.err or not candidate.result then
        return false
    end
    vim.cmd { cmd = splitcmd, args = { vim.uri_to_fname(candidate.result) } }
    return true
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
