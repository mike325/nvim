local nvim = require('nvim')

local configs = {
    iron = function(m)
        m.core.set_config({
            repl_open_cmd = "botright split"
        })
    end,
}

for name,setup in pairs(configs) do
    local ok, rc = pcall(require, name)
    if ok then
        setup(rc)
    end
end
