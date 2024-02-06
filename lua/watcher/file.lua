local realpath = require('utils.files').realpath
local normalize = require('utils.files').normalize

local Watcher = {}
Watcher.__index = Watcher

local function on_change(watcher, err, fname, status)
    -- Do work...
    if not watcher._wait then
        for _, cb in ipairs(watcher._cb) do
            cb(err, fname, status)
        end

        for _, autocmd_name in ipairs(watcher._autocmd) do
            if type(autocmd_name) == type '' then
                vim.api.nvim_exec_autocmds(autocmd_name, {
                    event = 'User',
                    data = {
                        err = err,
                        fname = fname,
                        status = status,
                    },
                })
            end
        end
    end

    -- Debounce: stop/start.
    watcher:stop()
    vim.defer_fn(function()
        watcher:start()
    end, 100)
end

-- TODO: Add support for autocmd groups ?
function Watcher:new(filename, autocmd, cb)
    vim.validate {
        filename = { filename, 'string' },
        autocmd = { autocmd, { 'function', 'string' } },
        cb = { cb, { 'function' }, true },
    }

    if not cb and type(autocmd) == 'function' then
        cb = { autocmd }
        autocmd = {}
    elseif type(autocmd) == type '' then
        autocmd = { autocmd }
    end

    if type(cb) ~= type {} then
        cb = { cb }
    end

    local watcher = vim.loop.new_fs_event()
    local obj = {
        _filename = realpath(normalize(filename)),
        _watcher = watcher,
        _cb = cb,
        _autocmd = autocmd,
        _wait = false,
    }

    return setmetatable(obj, self)
end

-- NOTE: For some reason we get notified more than once, need this flag and a defer to
-- mitigate this and get just 1 notification per change
function Watcher:start()
    self._wait = false
    self._watcher:start(
        self._filename,
        {
            watch_entry = false, -- true = when dir, watch dir inode, not dir content
            stat = false, -- true = don't use inotify/kqueue but periodic check, not implemented
            recursive = false, -- true = watch dirs inside dirs
        },
        vim.schedule_wrap(function(...)
            on_change(self, ...)
        end)
    )
end

function Watcher:stop()
    self._wait = true
    self._watcher:stop()
end

function Watcher:restart()
    self._watcher:stop()
    self._watcher:start()
end

function Watcher:subscribe(cb)
    vim.validate {
        cb = { cb, { 'function', 'string' } },
    }

    vim.list_extend(type(cb) == type '' and self._autocmd or self._cb, cb)
end

return Watcher
