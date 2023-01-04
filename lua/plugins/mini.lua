local nvim = require 'neovim'
local sys = require 'sys'

local is_dir = require('utils.files').is_dir
local mkdir = require('utils.files').mkdir
local completions = RELOAD('completions')

local load_module = require('utils.functions').load_module
local minidoc = load_module 'mini.doc'
local minisessions = load_module 'mini.sessions'

if minidoc then
    minidoc.setup {}
end

if minisessions then
    local sessions_dir = sys.data .. '/session'
    if not is_dir(sessions_dir) then
        mkdir(sessions_dir)
    end
    minisessions.setup {}
    nvim.command.set('SessionSave', function(opts)
        local session = opts.args
        if session == '' then
            local getcwd = require('utils.files').getcwd
            session = vim.v.this_session ~= '' and vim.v.this_session or vim.fs.basename(getcwd())
            if session:match '^%.' then
                session = session:gsub('^%.+', '')
            end
        end
        minisessions.write(session:gsub('%s+', '_'), { force = true })
    end, { nargs = '?', complete = completions.session_files })

    nvim.command.set('SessionLoad', function(opts)
        local session = opts.args
        if session ~= '' then
            minisessions.read(session, { force = false })
        else
            minisessions.get_latest()
        end
    end, { nargs = '?', complete = completions.session_files })

    nvim.command.set('SessionDelete', function(opts)
        local bang = opts.bang
        local session = opts.args
        local is_file = require('utils.files').is_file
        local path = sessions_dir .. '/' .. session
        if not is_file(path) then
            vim.notify('Invalid Session: ' .. session, 'ERROR', { title = 'MiniSession' })
            return
        end
        minisessions.delete(session, { force = bang })
    end, {
        bang = true,
        nargs = 1,
        complete = completions.session_files,
    })
end
