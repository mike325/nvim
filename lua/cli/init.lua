-- TODO: This is a setup for script run using -l flag
--
-- Missing things,
-- - stdio handle, specially stdin, stdout/stderr works using vim.notify custom backend
-- - arg parsing
-- - logging

if vim.loader then
    vim.loader.enable()
end

vim.g.has_ui = #vim.api.nvim_list_uis() > 0
vim.g.port = 0x8AC
vim.g.mapleader = ' '
vim.opt.termguicolors = true

require 'messages'
require 'globals'

local hosts = require('threads.parsers').sshconfig()
for host, attrs in pairs(hosts) do
    STORAGE.hosts[host] = attrs
end
