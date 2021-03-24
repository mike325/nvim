-- local nvim = require'nvim'
local sys = require'sys'

local is_file        = require'tools'.files.is_file
local readfile       = require'tools'.files.readfile
-- local read_json      = require'tools'.files.read_json
-- local normalize_path = require'tools'.files.normalize_path

local M = {
    hosts = {},
    remotes = {},
}

local function read_ssh_hosts(jobid, rc, _)
    local host = ''
    local ssh_config = sys.home..'/.ssh/config'
    if is_file(ssh_config) then
        for _,line in pairs(readfile(ssh_config)) do
            if line:match('Host [a-zA-Z0-9_-%.]+') then
                host = vim.split(line, ' ')[2]
            elseif line:match('%s+Hostname [a-zA-Z0-9_-%.]+') and host ~= '' then
                M.hosts[host] = vim.split(line, ' ')[2]
                host = ''
            end
        end
    end
end

function M.get_ssh_hosts()
    local cmd = sys.name == 'windows' and 'cmd /c "dir"' or 'ls .'
    require'jobs'.send_job{
        cmd = cmd,
        opts = {
            on_exit = read_ssh_hosts,
            on_stdout = function(jobid, rc, _) end, -- Dummy function
        },
    }
end

return M
