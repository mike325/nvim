local api = vim.api

local load_module = function(name)
    return require(name)
end

local ok, rc = pcall(load_module, 'iron')

if ok then
    local iron = rc

    if iron ~= nil then
        local split = api.nvim_get_option('splitbelow') and  'topleft' or 'botright'
        iron.core.set_config({
            repl_open_cmd = split.." split"
        })
    end
end
