local Config = {
    path = '',
    filename = '',
    global = {},
    sections = {},
}

local function read_config(config)
    local configfile = config.filename
    local data = require('utils.files').readfile(configfile)
    local parsers = require 'configfiles.parsers'

    local ext = require('utils.files').extension(configfile)
    local basename = require('utils.files').basename

    local base_filename = basename(configfile)
    local base_dir = basename(require('utils.files').basedir(config.path))

    if ext == 'toml' then
        return parsers.toml(data)
    elseif base_filename == '.gitconfig' or (base_dir == '.git' and base_filename == 'config') then
        return parsers.git(data)
    end

    return parsers.general(data)
end

function Config:new(configfile)
    vim.validate { configfile = { configfile, 'string' } }
    configfile = require('utils.files').normalize_path(configfile)
    vim.validate {
        configfile = {
            configfile,
            function(c)
                return require('utils.files').is_file(c)
            end,
            'config file',
        },
    }

    local obj = {}
    setmetatable(obj, self)
    self.__index = self
    self.filename = configfile
    self.path = require('utils.files').realpath(configfile)

    local data = read_config(self)
    self.global = data.global
    self.sections = data.sections
    return obj
end

return Config
