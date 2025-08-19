-- TODO: TOML and git specific parsers
return {
    general = require('configfiles.parsers.general').parser,
    git = require('configfiles.parsers.general').parser,
    toml = require('configfiles.parsers.general').parser,
}
