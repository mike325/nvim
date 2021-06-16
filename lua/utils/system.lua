-- local nvim = require'nvim'
local sys = require'sys'

local is_file    = require'utils.files'.is_file
local readfile   = require'utils.files'.readfile
local executable = require'utils.files'.executable
local realpath   = require'utils.files'.realpath
local split      = require'utils.strings'.split

-- local read_json      = require'utils'.files.read_json
-- local normalize_path = require'utils'.files.normalize_path

local M = {
    hosts = {},
    remotes = {},
}

function M.get_ssh_hosts()
    local ssh_config = sys.home..'/.ssh/config'
    if is_file(ssh_config) then
        local host = ''
        readfile(ssh_config, function(data)
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
                local job = require'jobs.storage'.jobs[jobid]
                if rc == 0 then
                    local dir = table.concat(job.streams.stdout, '')
                    pcall(callback, realpath(dir))
                end
            end,
        },
    }
end

return M
