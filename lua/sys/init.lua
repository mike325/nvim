local executable = function(exe)
    return vim.fn.executable(exe) == 1
end

local filereadable = function(filename)
    return vim.uv.fs_stat(filename) ~= nil
end

local function system_name()
    return jit.os:lower()
end

local function homedir()
    return vim.fs.normalize(vim.uv.os_homedir())
end

local function dirname()
    return vim.fs.normalize(vim.fn.stdpath 'config')
end

local function cachedir()
    return vim.fs.normalize(vim.fn.stdpath 'cache')
end

local function datadir()
    return vim.fs.normalize(vim.fn.stdpath 'data')
end

local function luajit_version()
    return jit and vim.split(jit.version, ' ')[2] or nil
end

local function version()
    return {
        vim.version().major,
        vim.version().minor,
        vim.version().patch,
    }
end

local function has_sqlite()
    local os_name = system_name()
    -- TODO: search for dll in windows, .so in unix
    if os_name == 'windows' then
        local sqlite_path = vim.fs.normalize(cachedir() .. '/sqlite3.dll')
        if filereadable(sqlite_path) then
            vim.g.sqlite_clib_path = sqlite_path
            return true
        end
        return false
    end

    local libsqlite = vim.fs.normalize(vim.fs.joinpath(homedir(), '.local', 'lib', 'libsqlite.so'))
    if filereadable(libsqlite) then
        vim.g.sqlite_clib_path = libsqlite
    end
    return executable 'sqlite3'
end

local function db_root_path()
    local root = vim.fs.normalize(vim.fs.joinpath(vim.fn.stdpath 'data', 'databases'))
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

for directory in vim.iter { 'backup', 'undo', 'sessions' } do
    sys[directory] = vim.fs.joinpath(sys.data, directory)
end
sys.swap = vim.fs.joinpath(vim.fn.stdpath 'state', 'swap')
return sys
