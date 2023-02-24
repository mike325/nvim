local sys = require 'sys'

local executable = require('utils.files').executable
local is_dir = require('utils.files').is_dir
local langservers = require 'plugins.lsp.servers'

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
                return not l or type(l) == type '' or vim.tbl_islist(l)
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
    elseif vim.tbl_islist(languages) then
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

return M
