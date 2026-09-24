local comp_utils = require 'completions.utils'

-- vim.api.nvim_create_user_command('Execute', function(opts)
--     local cpp_utils = require 'filetypes.cpp.utils'
--     cpp_utils.execute(nil, opts.fargs)
-- end, {
--     nargs = '*',
--     force = true,
--     buffer = true,
--     complete = 'file',
--     desc = 'Execute a binary from a build collateral',
-- })

vim.api.nvim_create_user_command('Build', function(opts)
    local args = {}
    vim.list_extend(args, opts.fargs)
    local cpp_utils = require 'filetypes.cpp.utils'
    cpp_utils.build(args)
end, {
    nargs = '*',
    force = true,
    buffer = true,
    complete = comp_utils.get_completion(vim.tbl_keys(require 'filetypes.cpp.build_types')),
    desc = 'Build C/C++ project',
})

-- TODO: Fallback to TermDebug
-- if nvim.plugins['nvim-dap'] then
--     vim.api.nvim_create_user_command('BuildDebugFile', function(opts)
--         local dap = vim.F.npcall(require, 'dap')
--         if not dap then
--             error(debug.traceback 'Missing DAP!')
--         end
--
--         local args = opts.fargs
--         local flags = {}
--
--         local cpp_utils = require 'filetypes.cpp.utils'
--
--         vim.list_extend(flags, args)
--         cpp_utils.build {
--             compiler = cpp_utils.get_compiler(),
--             build_type = 'debug',
--             flags = flags,
--             cb = function()
--                 dap.continue()
--             end,
--             single = true,
--         }
--     end, {
--         nargs = '*',
--         force = true,
--         buffer = true,
--     })
--
--     vim.api.nvim_create_user_command('BuildDebug', function(opts)
--         local dap = vim.F.npcall(require, 'dap')
--         if not dap then
--             error(debug.traceback 'Missing DAP!')
--         end
--
--         -- local args = opts.fargs
--         -- local flags = {}
--         -- vim.list_extend(flags, args)
--         local cpp_utils = require 'filetypes.cpp.utils'
--
--         cpp_utils.build {
--             compiler = cpp_utils.get_compiler(),
--             build_type = 'debug',
--             flags = opts.fargs,
--             cb = function()
--                 dap.continue()
--             end,
--         }
--     end, {
--         nargs = '*',
--         force = true,
--         buffer = true,
--     })
-- end
