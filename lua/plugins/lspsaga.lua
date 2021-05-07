-- luacheck: max line length 152
-- local nvim  = require'nvim'
-- local tools = require'tools'

-- local executable  = require'tools'.files.executable
local load_module = require'tools'.helpers.load_module
local get_icon    = require'tools'.helpers.get_icon

-- local set_mapping = nvim.mappings.set_mapping

local saga = load_module'lspsaga'

if not saga then
    return false
end

saga.init_lsp_saga{
    error_sign = get_icon('error'),
    warn_sign = get_icon('warn'),
    hint_sign = get_icon('hint'),
    infor_sign = get_icon('info'),
    -- dianostic_header_icon = '   ',
    -- code_action_icon = ' ',
    -- finder_definition_icon = '  ',
    -- finder_reference_icon = '  ',
    -- definition_preview_icon = '  ',
    rename_prompt_prefix = get_icon('virtual_text'),
    rename_action_keys = {
        quit = '<ESC>',
        exec = '<CR>',
    },
    code_action_keys = {
        quit = '<ESC>',
        exec = '<CR>',
    },
    finder_action_keys = {
        open = '<CR>',
        vsplit = 'V',
        split = 'X',
        quit = '<ESC>',
        scroll_down = '<C-u>',
        scroll_up = '<C-d>',
    },
}

return true
