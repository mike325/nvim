-- local nvim = require'nvim'
local sys = require'sys'

local is_file        = require'tools.files'.is_file
local async_readfile = require'tools.files'.async_readfile
local executable     = require'tools.files'.executable
local realpath       = require'tools.files'.realpath
local split          = require'tools.strings'.split

-- local read_json      = require'tools'.files.read_json
-- local normalize_path = require'tools'.files.normalize_path

local M = {
    hosts = {},
    remotes = {},
}

function M.get_ssh_hosts()
    local ssh_config = sys.home..'/.ssh/config'
    if is_file(ssh_config) then
        local host = ''
        async_readfile(ssh_config, function(data)
            for _,line in pairs(data) do
                if line and line ~= '' and line:match('Host [a-zA-Z0-9_-%.]+') then
                    host = split(line, ' ')[2]
                elseif line:match('%s+Hostname [a-zA-Z0-9_-%.]+') and host ~= '' then
                    M.hosts[host] = split(line, ' ')[2]
                    host = ''
                end
            end
        end)
    end
end

function M.get_git_dir(callback)
    assert(executable('git'), 'Missing git')
    assert(type(callback) == 'function', 'Missing callback function')

    local cmd = { 'git', 'rev-parse', '--git-dir' }
    require'jobs'.send_job{
        cmd = cmd,
        opts = {
            on_exit = function(jobid, rc, _)
                if rc == 0 then
                    local dir = vim.fn.join(require'jobs'.jobs[jobid].streams.stdout, '')
                    pcall(callback, realpath(dir))
                end
            end,
        },
    }
end

return M
