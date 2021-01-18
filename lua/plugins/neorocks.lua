-- -- luacheck: max line length 152
local nvim  = require'nvim'
local load_module = require'tools'.helpers.load_module

local set_command = nvim.commands.set_command

local neorocks = load_module'plenary.neorocks'

if not neorocks then
    return false
end

-- TODO: Pull request to make neorocks silent setup
set_command{
    lhs = 'NeorocksInstall',
    rhs = function(rock)
        neorocks.install(rock)
    end,
    args = {force=true}
}

set_command{
    lhs = 'NeorocksSetup',
    rhs = function()
        neorocks.setup(true, false)
    end,
    args = {force=true}
}

return true
