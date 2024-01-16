local orgmode = vim.F.npcall(require, 'orgmode')

if orgmode == nil then
    return false
end

local isdir = require('utils.files').is_dir
local mkdir = require('utils.files').mkdir
local executable = require('utils.files').executable

if not isdir '~/notes/' then
    mkdir '~/notes/'
end

local function general_success(format)
    vim.notify('Successfully exported to ' .. format, vim.log.levels.INFO, { title = 'Orgmode' })
end

local function general_error(err, format)
    vim.notify(table.concat(err, '\n'), vim.log.levels.ERROR, { title = 'Failed exporting to ' .. format })
end

local exporters = {}
if executable 'pandoc' then
    exporters.f = {
        label = 'Export to RTF format',
        action = function(exporter)
            local current_file = vim.api.nvim_buf_get_name(0)
            local target = vim.fn.fnamemodify(current_file, ':p:r') .. '.rtf'
            local command = { 'pandoc', current_file, '-o', target }
            local on_success = function(_)
                general_success 'RTF'
            end
            local on_error = function(err)
                general_error(err, 'RTF')
            end
            return exporter(command, target, on_success, on_error)
        end,
    }
end

orgmode.setup {
    org_agenda_files = { '~/notes/**/*' },
    org_default_notes_file = '~/notes/refile.org',
    org_todo_keywords = {
        'TODO',
        'WIP',
        '|',
        'DONE',
        'DROP',
    },
    org_todo_keyword_faces = {
        TODO = ':foreground Cyan',
        WIP = ':foreground Yellow',
        DONE = ':foreground Green',
        DROP = ':foreground Red',
    },
    org_custom_exports = exporters,
    mappings = {
        -- disable_all = true,
        -- global = {
        --     org_agenda = 'gA',
        --     org_capture = 'gC',
        -- },
        agenda = {
            org_agenda_later = '>',
            org_agenda_earlier = '<',
            org_agenda_goto_today = '.',
        },
        capture = {
            org_capture_finalize = '=D',
            org_capture_refile = '=R',
            org_capture_kill = '=Q',
        },
        -- org = {
        --     org_timestamp_up = '+',
        --     org_timestamp_down = '-',
        -- },
        -- text_objects = {
        --     inner_heading = 'ic',
        -- },
    },
}

return true
