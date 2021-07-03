local load_module = require'utils.helpers'.load_module

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
