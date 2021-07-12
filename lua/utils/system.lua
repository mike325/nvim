local sys = require'sys'

local is_file    = require'utils.files'.is_file
local readfile   = require'utils.files'.readfile
local executable = require'utils.files'.executable
local realpath   = require'utils.files'.realpath
local split      = require'utils.strings'.split

-- local read_json      = require'utils'.files.read_json
-- local normalize_path = require'utils'.files.normalize_path

local M = {}

function M.get_ssh_hosts()
    local ssh_config = sys.home..'/.ssh/config'
    if is_file(ssh_config) then
        local host = ''
        readfile(ssh_config, function(data)
            for _,line in pairs(data) do
                if line and line ~= '' and line:match('Host [a-zA-Z0-9_-%.]+') then
                    host = split(line, ' ')[2]
                elseif line:match('%s+Hostname [a-zA-Z0-9_-%.]+') and host ~= '' then
                    STORAGE.hosts[host] = split(line, ' ')[2]
                    host = ''
                end
            end
        end)
    end
end

function M.get_git_dir(callback)
    assert(executable('git'), 'Missing git')
    -- assert(type(callback) == 'function', 'Missing callback function')

    local Job = RELOAD'jobs'
    local j = Job:new{
        cmd = {'git', 'rev-parse', '--git-dir' },
        silent = true,
    }
    j:callback_on_success(function(job)
        local dir = table.concat(job:output(), '')
        pcall(callback, realpath(dir))
    end)
    j:start()
end

return M
