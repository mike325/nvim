local nvim = require('nvim')

nvim.plugs = nil
local ok, plugs = pcall(vim.api.nvim_get_var, 'plugs')

if ok then
    nvim.plugs = plugs
end

return nvim
