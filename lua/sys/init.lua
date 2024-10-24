local config_dirs = {
    'backup',
    'undo',
    'session',
}

local executable = function(exe)
    return vim.fn.executable(exe) == 1
end

local filereadable = function(filename)
    return vim.fn.executable(filename) == 1
end

local forward_slash = function(str)
    return str:gsub('\\', '/')
end

local function system_name()
    local name = jit.os:lower()
    return name
end

local function homedir()
    local home = vim.uv.os_homedir()
    return forward_slash(home)
end

local function dirname()
    return forward_slash(vim.fn.stdpath 'config')
end

local function cachedir()
    return forward_slash(vim.fn.stdpath 'cache')
end

local function datadir()
    return forward_slash(vim.fn.stdpath 'data')
end

local function luajit_version()
    return vim.split(jit.version, ' ')[2]
end

local function version()
    return {
        vim.version().major,
        vim.version().minor,
        vim.version().patch,
    }
end

local function has_sqlite()
    local os = system_name()
    -- TODO: search for dll in windows, .so in unix
    if os == 'windows' then
        local sqlite_path = forward_slash(cachedir() .. '/sqlite3.dll')
        if filereadable(sqlite_path) then
            vim.g.sqlite_clib_path = sqlite_path
            return true
        end
        return false
    end
    if filereadable(forward_slash(homedir() .. '/.local/lib/libsqlite.so')) then
        vim.g.sqlite_clib_path = forward_slash(homedir() .. '/.local/lib/libsqlite.so')
    end
    return executable 'sqlite3'
end

local function db_root_path()
    local root = forward_slash(vim.fn.stdpath 'data' .. '/databases')
    if vim.fn.isdirectory(root) ~= 1 then
        vim.fn.mkdir(root, 'p')
    end
    return root
end

local sys = {
    name = system_name(),
    home = homedir(),
    base = dirname(),
    data = datadir(),
    cache = cachedir(),
    luajit = luajit_version(),
    db_root = db_root_path(),
    has_sqlite = has_sqlite(),
    user = vim.uv.os_get_passwd(),
    version = version(),
}

sys.user.name = sys.user.username
sys.username = sys.user.username

function sys.tmp(filename)
    local tmpdir = sys.name == 'windows' and 'c:/temp/' or '/tmp/'
    return tmpdir .. filename
end

for _, dir_name in ipairs(config_dirs) do
    sys[dir_name] = sys.data .. '/' .. dir_name
end
sys.swap = vim.fn.stdpath 'state' .. '/swap'

return sys
