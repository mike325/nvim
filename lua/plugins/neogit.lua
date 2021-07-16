local load_module = require'utils.helpers'.load_module

local neogit = load_module'neogit'

if neogit == nil then
    return false
end

local has_diffview = load_module'diffview'

neogit.setup {
    -- disable_signs = true,
    disable_commit_confirmation = true,
    integrations = {
        diffview = has_diffview ~= nil,
    },
}

return true
