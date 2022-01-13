local M = {
    lua = {
        formatprg = require('filetypes.lua').formatprg,
        makeprg = require('filetypes.lua').makeprg,
    },
    python = {
        formatprg = require('filetypes.python').formatprg,
        makeprg = require('filetypes.python').makeprg,
    },
    cpp = {
        -- formatprg = require('filetypes.cpp').formatprg,
        makeprg = require('filetypes.cpp').makeprg,
    },
    c = {
        -- formatprg = require('filetypes.cpp').formatprg,
        makeprg = require('filetypes.cpp').makeprg,
    },
}

return M
