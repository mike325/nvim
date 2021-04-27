-- local nvim        = require'nvim'
-- local has_attrs   = require'tools'.tables.has_attrs
local load_module = require'tools'.helpers.load_module
local get_icon = require'tools'.helpers.get_icon
local get_separators = require'tools'.helpers.get_separators

local galaxyline = load_module'galaxyline'

if not galaxyline then
    return false
end

-- local extension = require('galaxyline.provider_extensions')
-- local buffer = require('galaxyline.provider_buffer')
-- local diagnostic = require('galaxyline.provider_diagnostic')
local vcs = require('galaxyline.provider_vcs')
local fileinfo = require('galaxyline.provider_fileinfo')
local devicon = require'nvim-web-devicons'.get_icon

local colors = require'plugins/colors'

local separators = get_separators('circle')

galaxyline.section.left = {}
galaxyline.section.right = {}

-- TODO:
-- * Paste
-- * Spell
-- * Word Count
-- * Mixed indentation
-- * Add support for Neomake and YCM errors
-- * Fix

local modes = {
    n        = {'N',  colors.purple},
    no       = {'N',  colors.purple},
    nov      = {'N',  colors.purple},
    noV      = {'N',  colors.purple},
    ['no'] = {'N',  colors.purple},
    niI      = {'N',  colors.purple},
    niR      = {'N',  colors.purple},
    niV      = {'N',  colors.purple},
    v        = {'V',  colors.cyan},
    V        = {'VL', colors.cyan},
    ['']   = {'VB', colors.cyan},
    s        = {'S',  colors.cyan},
    S        = {'SL', colors.cyan},
    ['']   = {'SB', colors.cyan},
    i        = {'I',  colors.light_yellow},
    ic       = {'I',  colors.light_yellow},
    ix       = {'I',  colors.light_yellow},
    R        = {'R',  colors.light_red},
    Rc       = {'R',  colors.light_red},
    Rv       = {'R',  colors.light_red},
    Rx       = {'R',  colors.light_red},
    c        = {'C',  colors.light_green},
    cv       = {'C',  colors.light_green},
    ce       = {'C',  colors.light_green},
    t        = {'T',  colors.pink},
    ['!']    = {'-',  colors.black},
    r        = {'-',  colors.black},
    rm       = {'-',  colors.black},
    ['r?']   = {'-',  colors.black},
}

local function mode_label()
    return modes[nvim.get_mode()['mode']][1]
end

local function mode_hl()
    return modes[nvim.get_mode()['mode']][2]
end

local function highlight(group, fg, bg, gui)
    local cmd = string.format('highlight %s guifg=%s guibg=%s', group, fg, bg)
    if gui ~= nil then
        cmd = cmd .. ' gui=' .. gui
    end
    vim.cmd(cmd)
end

local function buffer_not_empty()
    if vim.fn.empty(vim.fn.expand('%:t')) ~= 1 then
        return true
    end
    return false
end

-- local function wide_enough()
--     local squeeze_width = vim.fn.winwidth(0)
--     if squeeze_width > 80 then return true end
--     return false
-- end

local function has_diagnostics()
    if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
        local errors = vim.lsp.diagnostic.get_count(0, [[Error]])
        local warns = vim.lsp.diagnostic.get_count(0, [[Warning]])
        local hints = vim.lsp.diagnostic.get_count(0, [[Hint]])

        if errors > 0 or warns > 0 or hints > 0 then
            return true
        end
    end
    return false
end

local function is_vcs_repo()
    if vcs.get_git_branch() then
        return true
    end
    return false
end

galaxyline.section.left[#galaxyline.section.left + 1] = {
    LeftBegin = {
        provider = function() return separators.right end,
        separator = '',
        highlight = 'GalaxyViModeInv',
        separator_highlight = 'GalaxyViModeInv',
    }
}

galaxyline.section.left[#galaxyline.section.left + 1] = {
    Mode = {
        provider = function()
            local label = mode_label()
            local modehl = mode_hl()

            highlight('GalaxyViMode', colors.black, modehl)
            highlight('GalaxyViModeInv', modehl, colors.light_gray)

            return ('  %s '):format(label)
        end,
        -- icon = ('%s '):format(get_icon('bar')),
        highlight = 'GalaxyViMode',
        separator = ('%s  '):format(separators.left),
        separator_highlight = 'GalaxyViModeInv',
    },
}

galaxyline.section.left[#galaxyline.section.left + 1] = {
    GitBranch = {
        provider = 'GitBranch',
        condition = is_vcs_repo,
        icon = ('%s '):format(get_icon('git_branch')),
        highlight = {colors.white, colors.light_gray},
    },
}

galaxyline.section.left[#galaxyline.section.left + 1] = {
    DiffModified = {
        provider = 'DiffModified',
        condition = function()
            if vcs.diff_modified() then
                return true
            end
            return false
        end,
        icon = ('%s '):format(get_icon('diff_modified')),
        highlight = {colors.light_yellow, colors.light_gray},
    },
    DiffAdd = {
        provider = 'DiffAdd',
        condition = function()
            if vcs.diff_add() then
                return true
            end
            return false
        end,
        icon = ('%s '):format(get_icon('diff_add')),
        highlight = {colors.light_green, colors.light_gray},
    },
    DiffRemove = {
        provider = 'DiffRemove',
        condition = function()
            if vcs.diff_remove() then
                return true
            end
            return false
        end,
        icon = ('%s '):format(get_icon('diff_remove')),
        highlight = {colors.light_red, colors.light_gray},
    },
}

galaxyline.section.left[#galaxyline.section.left + 1] = {
    SepDiffEnd = {
        provider = function() return '' end,
        separator = separators.left,
        separator_highlight = {colors.light_gray, colors.dark_gray},
        condition = function() return not has_diagnostics() and is_vcs_repo() end,
    }
}

galaxyline.section.left[#galaxyline.section.left + 1] = {
    SepDiagBeg = {
        provider = function() return separators.left end,
        highlight = {colors.light_gray, colors.purple},
        separator = ' ',
        separator_highlight = {colors.purple, colors.purple},
        condition = has_diagnostics,
    }
}

galaxyline.section.left[#galaxyline.section.left + 1] = {
    DiagnosticError = {
        provider = function()
            if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
                local errors = vim.lsp.diagnostic.get_count(0, [[Error]])
                if errors > 0 then
                    return errors..' '
                end
            end
            return ''
        end,
        condition = function()
            if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
                local errors = vim.lsp.diagnostic.get_count(0, [[Error]])
                if errors > 0 then
                    return true
                end
            end
            return false
        end,
        icon = ('%s '):format(get_icon('error')),
        highlight = {colors.light_red, colors.purple},
    },
    DiagnosticWarn = {
        provider = function()
            if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
                local warns = vim.lsp.diagnostic.get_count(0, [[Warning]])
                if warns > 0 then
                    return warns..' '
                end
            end
            return ''
        end,
        condition = function()
            if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
                local warns = vim.lsp.diagnostic.get_count(0, [[Warning]])
                if warns > 0 then
                    return true
                end
            end
            return false
        end,
        icon = ('%s '):format(get_icon('warn')),
        highlight = {colors.light_yellow, colors.purple},
    },
    DiagnosticHint = {
        provider = function()
            if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
                local hints = vim.lsp.diagnostic.get_count(0, [[Hint]])
                if hints > 0 then
                    return hints..' '
                end
            end
            return ''
        end,
        condition = function()
            if not vim.tbl_isempty(vim.lsp.buf_get_clients(0)) then
                local hints = vim.lsp.diagnostic.get_count(0, [[Hint]])
                if hints > 0 then
                    return true
                end
            end
            return false
        end,
        icon = ('%s '):format(get_icon('info')),
        highlight = {colors.cyan, colors.purple},
    },
}

galaxyline.section.left[#galaxyline.section.left + 1] = {
    SepDiagEnd = {
        provider = function() return '' end,
        separator = separators.left,
        separator_highlight = {colors.purple, colors.dark_gray},
        condition = has_diagnostics,
    }
}

galaxyline.section.left[#galaxyline.section.left + 1] = {
    FileInfo = {
        provider = function()
            local filetypes = {
                help = '',
                log = '',
                fugitive = devicon('git'),
                gitcommit = devicon('git'),
            }

            local filename = fileinfo.get_current_file_name()
            local filetype = vim.bo.filetype
            local fileicon = filetypes[filetype] or devicon(filetype) or fileinfo.get_file_icon()

            -- local readonly = vim.bo.readonly and get_icon('readonly') or ''

            return ('  %s %s'):format(vim.trim(fileicon), vim.trim(filename))
        end,
        condition = buffer_not_empty,
        -- separator = ('%s'):format(separators.rights),
        -- separator_highlight = {colors.purple, colors.light_gray},
        highlight = {colors.white, colors.dark_gray},
    }
}

galaxyline.section.right[#galaxyline.section.right + 1] = {
    RightBegin = {
        provider = function() return ' ' end,
        separator = separators.right,
        highlight = {colors.purple, colors.purple},
        separator_highlight = {colors.purple, colors.dark_gray},
    }
}

galaxyline.section.right[#galaxyline.section.right + 1] = {
    FileFormat = {
        provider = function()
            local filesize   = vim.trim(fileinfo.get_file_size())
            local fileencode = vim.trim(fileinfo.get_file_encode())
            local fileformat = vim.trim(fileinfo.get_file_format())

            return ('%s [%s] %s '):format(fileformat, fileencode, filesize)
        end,
        condition = buffer_not_empty,
        highlight = {colors.white, colors.purple},
    },
}


galaxyline.load_galaxyline()

return true
