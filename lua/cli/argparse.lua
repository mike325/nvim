local Parser = {}
Parser.__index = Parser

function Parser:parse(args)
    vim.validate {
        args = { args, 'table', true },
    }

    args = vim.deepcopy(args or _G.arg or {})
    -- if next(self._flags) == nil then
    --     error(debug.traceback 'There are no flags to parse, use the add() method to create new rules')
    --     return
    -- end

    local parsed_args = {}
    local idx = 2
    while idx <= #args do
        local arg = args[idx]
        if arg == '-h' or arg == '--help' then
            vim.print(self:help())
            return parsed_args
        end

        local base_arg = arg
        if base_arg:match '^%-%-no%-?%w+' then
            base_arg = '--' .. (base_arg:gsub('^%-%-no%-?', ''))
        end

        if self._flags[base_arg] == nil then
            self:help()
            error(debug.traceback('Unknown argument: ' .. arg))
        else
            local val
            local flag = self._flags[base_arg]

            -- TODO: Support --flag <TRUTHY/FALSY>
            if flag.type == 'bool' or flag.type == 'boolean' then
                if #args[idx] == 2 then
                    val = true
                elseif args[idx]:match '^%-%-no%-?%w+' then
                    val = false
                else
                    val = true
                end
            elseif flag.type == 'number' then
                idx = idx + 1
                val = tonumber(args[idx])
                if not val then
                    error(debug.traceback(('%s expected a number, got %s'):format(arg, args[idx])))
                end
            elseif flag.type == 'string' then
                idx = idx + 1
                val = args[idx]
                if not val or val:match '^%-' then
                    error(debug.traceback(('%s expected a string'):format(arg)))
                end
            elseif flag.type == 'list' or flag.type == 'table' then
                idx = idx + 1
                val = args[idx]
                if not val or val:match '^%-' then
                    error(debug.traceback(('%s expected a list'):format(arg)))
                end
                val = vim.split(val, ',', { trimempty = true })
            end

            if val == nil then
                error(debug.traceback('Fail to parse: ' .. arg))
            end

            parsed_args[flag.name] = val
        end

        idx = idx + 1
    end

    return parsed_args
end

-- NOTE: Allow arg table to be passed ?
function Parser:new(description, name, version)
    vim.validate {
        description = { description, 'string', true },
        name = { name, 'string', true },
        version = { version, { 'string', 'number' }, true },
    }

    local obj = {}
    obj.description = description
    obj._flags = {}
    obj._name = name or (_G.arg and vim.fs.basename(_G.arg[0])) or 'nvim'
    obj._version = version or '0.1'
    obj._require_flags = 0
    obj = setmetatable(obj, self)
    -- obj:add {
    --     flags = { '-h', '--help' },
    --     type = 'boolean',
    --     name = 'help',
    --     description = 'Show help message',
    -- }
    return obj
end

function Parser:help()
    local help_str = [[

%s
Usage:
    %s %s

%s
]]

    local desc_str = ''
    if self.description then
        -- TODO: Add formatting options to wrap a certain column
        desc_str = ([[
Description:
    %s
]]):format(self.description)
    end

    -- TODO: Add support to auto add flags
    local flags_str = ''

    return help_str:format(desc_str, self._name, '[FLAGS]', flags_str)
end

function Parser:add(arg)
    -- TODO: Add support for custom function parsers
    -- TODO: Add dependency and exclusion between flags
    -- TODO: Add support for require and optional flags
    -- TODO: Add support for default values
    arg = arg or {}
    vim.validate {
        arg = { arg.flags, { 'table', 'string' } },
        flag_type = { arg.type, 'string' },
        description = { arg.description, 'string', true },
        name = { arg.name, 'string', true },
        -- default = { arg.default, arg.type, true },
        -- parser = { arg.parser, 'function', true },
    }

    local flags = type(arg.flags) == type {} and arg.flags or { arg.flags }

    local name = arg.name

    if not name then
        name = ''
        for _, flag in ipairs(flags) do
            local flag_basename = (flag:gsub('^%-+', ''))
            if #flag_basename > #name then
                name = flag_basename
            end
        end
    end

    for _, flag in ipairs(flags) do
        if self._flags[flag] then
            error(debug.traceback('Duplicated flag: ' .. flag))
        end

        self._flags[flag] = {
            type = arg.type,
            description = arg.description,
            name = name,
            -- parser = { arg.parser, 'function', true },
        }
    end
end

return Parser
