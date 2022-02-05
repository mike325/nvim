-- local nvim = require 'neovim'
local sys = require 'sys'

local is_dir = require('utils.files').is_dir
local mkdir = require('utils.files').mkdir

local load_module = require('utils.helpers').load_module
local minidoc = load_module 'mini.doc'
local minisession = load_module 'mini.sessions'

if minidoc then
    minidoc.setup {}
end

if minisession then
    local sessions_dir = sys.data .. '/session'
    if not is_dir(sessions_dir) then
        mkdir(sessions_dir)
    end
    minisession.setup {}
end
