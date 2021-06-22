local realpath       = require'utils.files'.realpath
local is_file        = require'utils.files'.is_file
local readfile       = require'utils.files'.readfile
local extension      = require'utils.files'.extension
local basename       = require'utils.files'.basename
local basedir        = require'utils.files'.basedir
local normalize_path = require'utils.files'.normalize_path

local Config = {
    path = '',
    filename = '',
    global = {},
    sections = {},
}

local function read_config(config)
    local configfile = config.filename
    local data = readfile(configfile)
    local parsers = require'configfiles.parsers'

    local ext = extension(configfile)
    local base_filename = basename(configfile)
    local base_dir = basename(basedir(config.path))

    if ext == 'toml' then
        return parsers.toml(data)
    elseif base_filename == '.gitconfig' or (base_dir == '.git' and base_filename == 'config') then
        return parsers.git(data)
    end

    return parsers.general(data)
end

function Config:new(configfile)
    configfile = normalize_path(configfile)
    assert(is_file(configfile), 'Not a valid configfile: '..configfile)

    obj = obj or {}
    setmetatable(obj, self)
    self.__index = self
    self.filename = configfile
    self.path = realpath(configfile)

    local data = read_config(self)
    self.global = data.global
    self.sections = data.sections
    return obj
end

return Config
