local uv = vim.loop

local M = {}

local function create_server(host, port, on_connection)
    local server = uv.new_tcp()
    server:bind(host, port)

    server:listen(128, function(err)
        assert(not err, err)
        local client = uv.new_tcp()
        server:accept(client)
        on_connection(client)
    end)

    return server
end

-- TODO: Support bang and disable flags
function M.start_server(opts)
    if opts.enable and STORAGE.servers[vim.g.port] and STORAGE.servers[vim.g.port]:is_active() then
        vim.notify('Server already enabled', vim.log.levels.INFO)
        return
    end

    local server
    server = create_server('127.0.0.1', vim.g.port, function(client)
        client:read_start(function(err, chunk)
            assert(not err, err)

            if chunk then
                local ok, json = pcall(vim.json.decode, chunk)
                if ok then
                    local stop = false
                    for action, data in pairs(json) do
                        if action == 'notification' then
                            local level = 'INFO'
                            if data:match '[fF][aA][iI][lL]' or data:match '[eE][rR][eR][oO][rR]' then
                                level = 'ERROR'
                            end
                            vim.notify(data, level, { title = 'Remote Notification' })
                        elseif action == 'stop' then
                            stop = true
                        end
                    end
                    if stop then
                        print 'Stopping server'
                        client:close()
                        server:shutdown()
                        server:close()
                        -- TODO: look if there's a shutdown/exit callback to make this cleanup
                        STORAGE.servers[vim.g.port] = nil
                    end
                else
                    client:write('non valid data: ' .. chunk)
                end
            else
                client:close()
            end
        end)
    end)

    if server:is_active() then
        STORAGE.servers[vim.g.port] = server
    else
        vim.notify(
            'Port: ' .. vim.g.port .. ' is already being used',
            vim.log.levels.ERROR,
            { title = 'NotificationServer' }
        )
    end
end

return M
