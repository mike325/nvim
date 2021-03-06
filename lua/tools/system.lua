local nvim = require'nvim'
local sys = require'sys'
-- local echoerr = require'tools'.messages.echoerr
-- local normalize_path = require'tools'.files.normalize_path
-- local is_file = require'tools'.files.is_file

local M = {
    hosts = {}
}

function M.read_ssh_hosts()
    local host = ''
    for _,line in pairs(nvim.fn.readfile(sys.home..'/.ssh/config')) do
        if line:match('Host [a-zA-Z0-9_-%.]+') then
            host = vim.split(line, ' ')[2]
        elseif line:match('%s+Hostname [a-zA-Z0-9_-%.]+') and host ~= '' then
            M.hosts[host] = vim.split(line, ' ')[2]
            host = ''
        end
    end
end


return M
