local nvim = require('mikecommon/nvim')

local function convert2settings(name)
    if name:find('-', 1, true) or name:find('.', 1, true) then
        -- name =
    end
    name = name:lower()
    return name
end

local function plugins_settings()
    for plugin,data in pairs(nvim.plugs) do
        local name = plugin
        local func_name = convert2settings(name)
        local ok, error_code = pcall(vim.api.nvim_call_function, 'plugins#'..name..'init', data)
        if not ok then
            print('Something failed '..error_code..' trying to call '..'plugins#'..name..'init')
            vim.api.nvim_command('echoerr ' .. error_code)
        end
    end
end

plugins_settings()
