local null_ls = vim.F.npcall(require, 'null-ls')

local is_absolute = require('utils.files').is_absolute
if not null_ls then
    return {}
end

local M = {}
local languages = vim.tbl_map(vim.fs.basename, vim.api.nvim_get_runtime_file('lua/filetypes/*.lua', true))

-- TODO: Respect config files Ex. compile_commands.json, stylua.toml, pyproject.toml, etc
for _, lang in ipairs(languages) do
    lang = lang:gsub('%.lua$', '')
    local ok, module = pcall(require, 'filetypes.' .. lang)
    if ok then
        if module.get_formatter or module.get_linter then
            M[lang] = {
                servers = {},
            }
        end
        -- TODO: get_(formatter/linter) returns the current linter/formatter with
        --       the "correct args" this means they sometimes looks for
        --       config files and they may even try to parse them, we may need a "simpler" version
        --       that just returns the correct executable and delay this lookups and parsing features to
        --       the actual execution
        if module.get_formatter then
            local formatter = module.get_formatter(true)
            if formatter then
                local cmd = formatter[1]
                local cmd_path
                if is_absolute(cmd) or cmd:sub(1, 1) == '.' then
                    cmd = cmd:gsub('.*/', '')
                    cmd_path = formatter[1]
                end
                cmd = cmd:gsub('%-', '_')
                if null_ls.builtins.formatting[cmd] then
                    local node = null_ls.builtins.formatting[cmd].with {
                        command = cmd_path,
                        extra_args = function(_)
                            local format_cmd = module.get_formatter(true)
                            return vim.list_slice(format_cmd, 2, #format_cmd)
                        end,
                    }
                    M[lang].formatter = node
                    table.insert(M[lang].servers, node)
                end
            end
        end
        if module.get_linter then
            local linter = module.get_linter()
            if linter then
                local cmd = linter[1]
                local cmd_path
                if is_absolute(cmd) or cmd:sub(1, 1) == '.' then
                    cmd = cmd:gsub('.*/', '')
                    cmd_path = linter[1]
                end

                cmd = cmd:gsub('%-', '_')
                if null_ls.builtins.diagnostics[cmd] then
                    local node = null_ls.builtins.diagnostics[cmd].with {
                        command = cmd_path,
                        extra_args = function(_)
                            local lint_cmd = module.get_linter()
                            return vim.list_slice(lint_cmd, 2, #lint_cmd)
                        end,
                    }
                    M[lang].linter = node
                    table.insert(M[lang].servers, node)
                end
            end
        end
        if M[lang] and #M[lang].servers == 0 then
            M[lang] = nil
        end
    end
end

M.c = M.cpp
M.bash = M.sh

if vim.fn.executable 'jq' == 1 then
    M.json = M.json or { servers = {} }
    local node = null_ls.builtins.formatting.jq
    M.json.formatter = node
    table.insert(M.json.servers, node)
end

return M
