local load_module = function(name)
    return require(name)
end

local ok, rc = pcall(load_module, 'iron')

if ok then
    local iron = rc

    if iron ~= nil then
        iron.core.set_config({
            repl_open_cmd = "botright split"
        })
    end
end
