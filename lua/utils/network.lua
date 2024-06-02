local M = {}

local prompt = 'Hostname > '
local completion = "customlist,v:lua.require'completions'.ssh_hosts_completion"
local error_msg = 'Missing hostname!'

function M.get_ssh_host(host, cb)
    vim.validate {
        host = { host, 'string', true },
        cb = { cb, 'function', true },
    }

    local function get_actual_hostname(hostname)
        if STORAGE.hosts[hostname] then
            if STORAGE.hosts[hostname].user then
                hostname = string.format('%s@%s', STORAGE.hosts[hostname].user, STORAGE.hosts[hostname].hostname)
            else
                hostname = STORAGE.hosts[hostname].hostname
            end
        end
        return hostname
    end

    if not host or host == '' then
        local title = 'GetSshHost'

        if cb then
            vim.ui.input({
                prompt = prompt,
                completion = completion,
            }, function(input)
                if not input or input == '' then
                    vim.notify(error_msg, vim.log.levels.ERROR, { title = title })
                    return false
                end
                cb(get_actual_hostname(input))
            end)
            return
        else
            host = vim.fn.input(prompt, '', completion)
            if not host or host == '' then
                vim.notify(error_msg, vim.log.levels.ERROR, { title = title })
                return false
            end
        end
    end
    return get_actual_hostname(host)
end

function M.get_remote_host(host, cb)
    vim.validate {
        host = { host, 'string', true },
        cb = { cb, 'function', true },
    }

    local function get_actual_hostname(hostname)
        if STORAGE.hosts[hostname] then
            hostname = STORAGE.hosts[hostname].hostname
        end
        return hostname
    end

    if not host or host == '' then
        local title = 'GetRemoteHost'

        if cb then
            vim.ui.input({
                prompt = prompt,
                completion = completion,
            }, function(input)
                if not input or input == '' then
                    vim.notify(error_msg, vim.log.levels.ERROR, { title = title })
                    return false
                end
                cb(get_actual_hostname(input))
            end)
            return
        else
            host = vim.fn.input(prompt, '', completion)
            if not host or host == '' then
                vim.notify(error_msg, vim.log.levels.ERROR, { title = title })
                return false
            end
        end
    end
    return get_actual_hostname(host)
end

return M
