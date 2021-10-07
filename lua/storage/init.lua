-- local _, sqlite = pcall(require, 'sqlite')

if not STORAGE.db_path then
    STORAGE.db_path = ('%s/aztlan.db'):format(vim.fn.stdpath('data'):gsub('\\', '/'))
end

require('storage.versions').setup()

local M = {
    get_version = require('storage.versions').get_version,
    set_version = require('storage.versions').set_version,
    check_version = require('storage.versions').check_version,
    has_version = require('storage.versions').has_version,
}

return M
