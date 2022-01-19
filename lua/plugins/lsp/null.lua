local load_module = require('utils.helpers').load_module
local null_ls = load_module 'null-ls'

local is_absolute = require('utils.files').is_absolute

if not null_ls then
    return {}
end

local languages = { 'cpp', 'lua', 'python', 'vim', 'sh' }
local M = {}

-- TODO: Respect config files Ex. compile_commands.json, stylua.toml, pyproject.toml, etc
for _, lang in ipairs(languages) do
    local ok, module = pcall(require, 'filetypes.' .. lang)
    if ok then
        if module.get_formatter or module.get_linter then
            M[lang] = {}
        end
        if module.get_formatter then
            -- TODO: get_formatter checks for a lot of things, maybe just need to return the executable
            local formatter = module.get_formatter()
            if formatter then
                local cmd = formatter[1]
                local cmd_path
                if is_absolute(cmd) or cmd:sub(1, 1) == '.' then
                    cmd = cmd:gsub('.*/', '')
                    cmd_path = formatter[1]
                end
                if null_ls.builtins.formatting[cmd] then
                    table.insert(
                        M[lang],
                        null_ls.builtins.formatting[cmd].with {
                            command = cmd_path,
                            extra_args = function(param)
                                local format_cmd = module.get_formatter()
                                return vim.list_slice(format_cmd, 2, #format_cmd)
                            end,
                        }
                    )
                end
            end
        end
        if module.get_linter then
            -- TODO: get_linter checks for a lot of things, maybe just need to return the executable
            local linter = module.get_linter()
            if linter then
                local cmd = linter[1]
                local cmd_path
                if is_absolute(cmd) or cmd:sub(1, 1) == '.' then
                    cmd = cmd:gsub('.*/', '')
                    cmd_path = linter[1]
                end
                if null_ls.builtins.diagnostics[cmd] then
                    table.insert(
                        M[lang],
                        null_ls.builtins.diagnostics[cmd].with {
                            command = cmd_path,
                            extra_args = function(param)
                                local lint_cmd = module.get_linter()
                                return vim.list_slice(lint_cmd, 2, #lint_cmd)
                            end,
                        }
                    )
                end
            end
        end
    end
end

M.c = M.cpp
M.bash = M.sh

return M
