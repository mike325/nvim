-- luacheck: globals unpack vim
local nvim = require('nvim')
local line = require('nvim').fn.line

local helpers = {}

function helpers.LastPosition()
    local sc_mark = nvim.buf.get_mark(0, "'")[1]
    local dc_mark = nvim.buf.get_mark(0, '"')[1]
    local last_line = line('$')
    local filetype = nvim.bo.filetype

    local black_list = {
        git = 1,
        gitcommit = 1,
        fugitive = 1,
        qf = 1,
    }

    if sc_mark >= 1 and dc_mark <= last_line and black_list[filetype] == nil then
        nvim.command([[normal! g'"]])
    end
end

return helpers
