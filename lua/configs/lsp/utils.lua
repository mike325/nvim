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

function M.check_language_server(languages)
    vim.validate {
        languages = {
            languages,
            function(l)
                return not l or type(l) == type '' or vim.islist(l)
            end,
            'a string or a list of strings',
        },
    }

    if not languages or #languages == 0 then
        for _, servers in pairs(langservers) do
            local server_idx = check_lsp(servers)
            if server_idx then
                return server_idx
            end
        end
    elseif vim.islist(languages) then
        for _, language in pairs(languages) do
            local servers = langservers[language]
            if servers then
                local server_idx = check_lsp(servers)
                if server_idx then
                    return server_idx
                end
            end
        end
    elseif langservers[languages] then
        return check_lsp(langservers[languages])
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
    if lsp then
        bufnr = require('lspconfig').util.validate_bufnr(bufnr)
    end
    local params = { uri = vim.uri_from_bufnr(bufnr) }
    local clients = vim.lsp.get_clients { name = 'clangd', bufnr = vim.api.nvim_get_current_buf() }
    local server = clients[1]
    if not server then
        return false
    end
    local candidate = server.request_sync('textDocument/switchSourceHeader', params, 1000, bufnr)
    if not candidate or type(candidate) == type '' or candidate.err then
        -- error(debug.traceback(candidate or 'Failed to execute switchSourceHeader'))
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
