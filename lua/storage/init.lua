-- local _, sqlite = pcall(require, 'sqlite')
local sys = require 'sys'

if not STORAGE.db_path then
    STORAGE.db_path = sys.db_root .. '/aztlan.db'
end

require('storage.versions').setup()

local M = {
    get_version = require('storage.versions').get_version,
    set_version = require('storage.versions').set_version,
    has_version = require('storage.versions').has_version,
    check_version = require('storage.versions').check_version,
}

return M
