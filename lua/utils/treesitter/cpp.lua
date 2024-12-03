local M = {}

function M.add_include(module, module_type)
    vim.validate {
        module = { module, 'string' },
        module_type = { module_type, 'string', true },
    }
    assert(
        not module_type or module_type == 'system' or module_type == 'sys' or module_type == 'local',
        debug.traceback 'module_type must be either sys or local'
    )

    local sysinc = '<%s>'
    local localinc = '"%s"'

    module_type = module_type or 'sys'
    module = module_type == 'sys' and sysinc:format(module) or localinc:format(module)

    local include_query = [[
        (preproc_include _ @modules (#lua-match? @modules "[<\"](.+)[>\"]"))
    ]]
    local local_query = [[
        (preproc_include (string_literal) @modules (#lua-match? @modules "\"(.+)\""))
    ]]
    local system_query = [[
        (preproc_include (system_lib_string) @modules (#lua-match? @modules "<(.+)>"))
    ]]

    local buf = vim.api.nvim_get_current_buf()
    local includes = RELOAD('utils.treesitter').list_buf_nodes(include_query, buf)
    local modules = RELOAD('utils.treesitter').list_buf_nodes(module_type == 'sys' and system_query or local_query, buf)
    if #includes > 0 then
        local has_module = false
        for _, include in ipairs(modules) do
            if include[1] == module then
                has_module = true
                break
            end
        end

        local last_include = #modules > 0 and modules[#modules] or includes[#includes]
        local index = last_include[2]
        if not has_module then
            vim.api.nvim_buf_set_lines(buf, index, index, true, { '#include ' .. module })
        end
    end
end

function M.get_class_operators(text)
    vim.validate {
        text = { text, 'boolean', true },
    }

    local functions = {}

    local ts_utils = RELOAD 'utils.treesitter'
    local class_node = ts_utils.get_current_class()
    if not class_node then
        vim.notify('Cursor is not inside a class', vim.log.levels.ERROR)
        return functions
    end

    local copy_move_functions = [[
        (class_specifier body:(field_declaration_list (function_definition ) @operator ))
        (struct_specifier body:(field_declaration_list (function_definition) @operator))
        ((declaration declarator:(function_declarator declarator:(destructor_name (identifier)))) @destructor)
    ]]

    return ts_utils.get_list_nodes(class_node, copy_move_functions, text)
end

return M
