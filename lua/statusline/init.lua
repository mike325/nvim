local nvim = require 'nvim'
local sys = require 'sys'
local getcwd = require('utils.files').getcwd
local get_icon = require('utils.functions').get_icon

local function qf_counter(loc)
    local title = loc and 'Loc' or 'Qf'
    local qf_values = require('utils.qf').get_list({ items = 0, idx = 0 }, loc)
    if #qf_values.items > 0 then
        local valid = 0
        for _, item in ipairs(qf_values.items) do
            if item.valid == 1 then
                valid = valid + 1
            end
        end
        if valid > 0 then
            return ('%s %s:%s'):format(title, qf_values.idx, valid)
        end
    end
    return ''
end

local function spaces_cond()
    local ft = vim.bo.filetype
    local ro = vim.bo.readonly
    local mod = vim.bo.modifiable
    local disable = {
        help = true,
        log = true,
    }
    return not disable[ft] and not ro and mod
end

local filename = {
    component = function()
        local buf = vim.api.nvim_get_current_buf()
        local bufname = vim.api.nvim_buf_get_name(buf)

        local modified = require('utils.buffers').is_modified(buf)
        local readonly = vim.bo[buf].readonly
        local ft = vim.bo[buf].filetype
        local buftype = vim.bo[buf].buftype

        -- TODO: Improve fugitve and other plugin support
        local plugins = {
            fugitive = 'Fugitive',
            telescope = 'Telescope',
            telescopeprompt = 'Telescope',
        }

        local filetypes = {
            gitcommit = 'COMMIT_MSG',
            GV = 'GV',
        }

        local name

        if plugins[ft:lower()] then
            return ('[%s]'):format(plugins[ft:lower()])
        elseif filetypes[ft] then
            name = filetypes[ft]
        elseif buftype == 'terminal' then
            name = 'term://' .. (bufname:gsub('term://.*:', ''))
        elseif buftype == 'help' then
            name = vim.fs.basename(bufname)
        elseif buftype == 'prompt' then
            name = '[Prompt]'
        elseif bufname == '' then
            name = '[No Name]'
        else
            local cwd = vim.pesc(getcwd())
            local separator = require('utils.files').separator()
            -- TODO: Cut this to respect the size
            name = vim.fn.bufname(buf)
            if name:match('^' .. cwd) then
                name = name:gsub('^' .. cwd, '')
                name = name:sub(1, 1) == separator and name:sub(2, #name) or name
            end
        end

        return name .. (modified and '[+]' or '') .. (readonly and ' ' .. get_icon 'readonly' or '')
    end,
}

local M = {
    filename = filename,
    mode = {
        component = function()
            local mode = vim.api.nvim_get_mode().mode
            if mode == 'V' then
                mode = 'VL'
            elseif mode == vim.keycode '<c-v>' then
                mode = 'VB'
            end
            return mode:upper()
        end,
    },
    wordcount = {
        component = function()
            local words = vim.fn.wordcount()['words']
            return 'Words: ' .. words
        end,
        cond = function()
            local ft = vim.bo.filetype
            local count = {
                latex = true,
                tex = true,
                markdown = true,
                vimwiki = true,
            }
            return count[ft] ~= nil
        end,
    },
    project_root = {
        component = function()
            local cwd = getcwd():gsub('\\', '/')
            return cwd:gsub(sys.home, '~')
        end,
    },
    spell = {
        component = function()
            if vim.wo.spell then
                local lang = vim.bo.spelllang or 'en'
                return ('[%s]'):format(lang:upper())
            end
            return ''
        end,
    },
    session = {
        component = function()
            if vim.v.this_session ~= '' then
                local session = vim.v.this_session
                return ('S: %s'):format((session:gsub('^.+/', '')))
            end
            return ''
        end,
        cond = function()
            return vim.v.this_session ~= ''
        end,
    },
    dap = {
        component = function()
            if nvim.plugins['nvim-dap'] and vim.g.dap_sessions_started then
                return vim.F.npcall(require, 'dap').status()
            end
            return ''
        end,
        cond = function()
            return nvim.plugins['nvim-dap'] and vim.g.dap_sessions_started
        end,
    },
    arglist = {
        component = function()
            local arglist_size = vim.fn.argc()
            if arglist_size > 0 then
                return ('%s %s:%s'):format('Arglist', vim.fn.argidx() + 1, arglist_size)
            end
            return ''
        end,
        cond = function()
            return vim.fn.argc() > 0
        end,
    },
    jobs = {
        component = function()
            local procs = #vim.api.nvim_get_proc_children(vim.uv.os_getpid())
            if procs > 0 then
                return ('%s: %s'):format('Jobs', procs)
            end
            return ''
        end,
    },
    clearcase = {
        component = function()
            if vim.env.CLEARCASE_ROOT then
                local view_name = vim.env.CLEARCASE_ROOT
                local pattern = '^/view/' .. sys.username .. '_at_'
                if view_name:match(pattern) then
                    view_name = (view_name:gsub(pattern, ''))
                end
                return ' ' .. view_name
            end
            return ''
        end,
    },
    mixindent = {
        component = function()
            local mix = vim.fn.search([[\v( \t|\t )]], 'nwc')
            if mix ~= 0 then
                return 'Mix indent'
            end
            return ''
        end,
        cond = spaces_cond,
    },
    trailspace = {
        component = function()
            local space = vim.fn.search([[\s\+$]], 'nwc')
            if space ~= 0 then
                return 'TS'
            end
            return ''
        end,
        cond = spaces_cond,
    },
    qf_counter = {
        component = function()
            return qf_counter(false)
        end,
        cond = function()
            return #vim.fn.getqflist() > 0
        end,
    },
    loc_counter = {
        component = function()
            return qf_counter(true)
        end,
        cond = function()
            return #vim.fn.getloclist(vim.api.nvim_get_current_win()) > 0
        end,
    },
    git_branch = {
        component = function(branch, icon)
            branch = branch or ''
            if not branch or branch == '' and vim.t.git_info and vim.t.git_info.branch then
                branch = vim.t.git_info.branch
            end

            if branch and branch ~= '' then
                local shrink
                local patterns = {
                    '^(%w+[/-]%w+[/-]%d+[/-])',
                    '^(%w+[/-]%d+[/-])',
                    '^(%w+[/-])',
                }
                if #branch > 30 and vim.g.short_branch_name then
                    for _, pattern in ipairs(patterns) do
                        shrink = branch:match(pattern)
                        if shrink then
                            branch = shrink:sub(1, #shrink - 1)
                            break
                        end
                    end
                elseif #branch > 15 then
                    for _, pattern in ipairs(patterns) do
                        shrink = branch:match(pattern)
                        if shrink then
                            branch = branch:gsub(vim.pesc(shrink), '')
                            break
                        end
                    end
                end
                if icon then
                    branch = string.format('%s %s', get_icon 'git_branch', branch)
                end
            end

            return branch
        end,
        cond = function()
            return vim.t.git_info ~= nil
        end,
    },
}

for _, component in pairs(M) do
    setmetatable(component, {
        __call = function(self)
            return self.component
        end,
    })
end

return M
