---@brief
---
--- https://github.com/MaskRay/ccls/wiki
---
--- ccls relies on a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html) specified
--- as compile_commands.json or, for simpler projects, a .ccls.
--- For details on how to automatically generate one using CMake look [here](https://cmake.org/cmake/help/latest/variable/CMAKE_EXPORT_COMPILE_COMMANDS.html). Alternatively, you can use [Bear](https://github.com/rizsotto/Bear).
---
--- Customization options are passed to ccls at initialization time via init_options, a list of available options can be found [here](https://github.com/MaskRay/ccls/wiki/Customization#initialization-options). For example:
---
--- ```lua
--- vim.lsp.config("ccls", {
---   init_options = {
---     compilationDatabaseDirectory = "build";
---     index = {
---       threads = 0;
---     };
---     clang = {
---       excludeArgs = { "-frounding-math"} ;
---     };
---   }
--- })
--- ```

local compile_db = 'compile_commands.json'

local root_markers = {
    '.ccls',
    -- '.clangd',
    '.clang-tidy',
    '.clang-format',
    compile_db,
    'compile_flags.txt',
    'configure.ac', -- AutoTools
    'Makefile',
    'CMakeLists.txt',
    '.git',
}

return {
  cmd = { 'ccls' },
  filetypes = { 'c', 'cpp', 'objc', 'objcpp', 'cuda' },
  root_markers = root_markers,
  offset_encoding = 'utf-32',
  -- ccls does not support sending a null root directory
  workspace_required = true,
  on_attach = function(client, bufnr)
        vim.api.nvim_buf_create_user_command(0, 'CCLSSwitch', function()
            require('configs.lsp.utils').switch_source_header_splitcmd(0, 'edit', 'ccls')
        end, { desc = 'Switch between source/header' })

        vim.api.nvim_buf_create_user_command(0, 'CCLSSwitchVSplit', function()
            require('configs.lsp.utils').switch_source_header_splitcmd(0, 'vsplit', 'ccls')
        end, { desc = 'Switch between source/header' })

        vim.api.nvim_buf_create_user_command(0, 'CCLSSwitchSplit', function()
            require('configs.lsp.utils').switch_source_header_splitcmd(0, 'split', 'ccls')
        end, { desc = 'Switch between source/header' })
  end,
}
