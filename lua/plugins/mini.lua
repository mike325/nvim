-- local nvim = require 'neovim'
local sys = require 'sys'

local is_dir = require('utils.files').is_dir
local mkdir = require('utils.files').mkdir

-- local nvim = require 'noevim'
local set_command = require('neovim.commands').set_command

local load_module = require('utils.helpers').load_module
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
    set_command {
        lhs = 'SessionSave',
        rhs = function(session)
            if not session or session == '' then
                local basename = require('utils.files').basename
                local getcwd = require('utils.files').getcwd
                session = vim.v.this_session ~= '' and vim.v.this_session or basename(getcwd())
                if session:match '^%.' then
                    session = session:gsub('^%.+', '')
                end
            end
            minisessions.write(session:gsub('%s+', '_'), { force = true })
        end,
        args = { nargs = '?', force = true, complete = [[customlist,v:lua._completions.session_files]] },
    }

    set_command {
        lhs = 'SessionLoad',
        rhs = function(session)
            if session and session ~= '' then
                minisessions.read(session, { force = false })
            else
                minisessions.get_latest()
            end
        end,
        args = { nargs = '?', force = true, complete = [[customlist,v:lua._completions.session_files]] },
    }

    set_command {
        lhs = 'SessionDelete',
        rhs = function(bang, session)
            local is_file = require('utils.files').is_file
            local path = sessions_dir .. '/' .. session
            if not is_file(path) then
                vim.notify('Invalid Session: ' .. session, 'ERROR', { title = 'MiniSession' })
                return
            end
            minisessions.delete(session, { force = bang })
        end,
        args = {
            bang = true,
            nargs = '1',
            force = true,
            complete = [[customlist,v:lua._completions.session_files]],
        },
    }
end
