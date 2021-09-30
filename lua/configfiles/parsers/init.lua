-- TODO: TOML and git specific parsers
local M = {
    general = require('configfiles.parsers.general').parser,
    git = require('configfiles.parsers.general').parser,
    toml = require('configfiles.parsers.general').parser,
}

return M
