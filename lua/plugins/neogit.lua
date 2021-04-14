-- luacheck: max line length 180
-- local sys  = require'sys'
-- local nvim = require'nvim'

local load_module = require'tools'.helpers.load_module

-- local set_command = nvim.commands.set_command
-- local set_autocmd = nvim.autocmds.set_autocmd
-- local set_mapping = nvim.mappings.set_mapping

local neogit = load_module'neogit'

if neogit == nil then
    return false
end

neogit.setup {
    -- mappings = {
    --     -- modify status buffer mappings
    --     status = {
    --         -- Adds a mapping with "B" as key that does the "BranchPopup" command
    --         -- ["B"] = "BranchPopup",
    --         -- Removes the default mapping of "s"
    --         -- ["s"] = "",
    --     }
    -- }
}

return true
