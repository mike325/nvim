local nvim        = require'nvim'
-- local has_attrs   = require'tools'.tables.has_attrs
local load_module = require'tools'.helpers.load_module
-- local get_icon = require'tools'.helpers.get_icon
-- local get_separators = require'tools'.helpers.get_separators

local pears = load_module'pears'

if not pears then
    return false
end

pears.setup(function(conf)
  conf.expand_on_enter(false)
end)

return true
