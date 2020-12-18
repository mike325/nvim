local sys  = require'sys'
local nvim = require'nvim'

-- local line         = nvim.fn.line
-- local system       = nvim.fn.system
local rename       = nvim.fn.rename
local bufloaded    = nvim.bufloaded
local isdirectory  = nvim.isdirectory
local filereadable = nvim.filereadable

local M = {}

function M.ls(expr)
    expr = expr == nil and {} or expr

    local search
    local path = expr.path
    local glob = expr.glob
    local filter = expr.type

    if glob == nil and path == nil then
        path = path == nil and '.' or path
        glob = glob == nil and '*' or glob
    end

    if path ~= nil and glob ~= nil then
        search = path..'/'..glob
    else
        search = path == nil and glob or path
    end

    local results = nvim.fn.glob(search, false, true, false)

    local filter_func = {
        file = filereadable,
        dir  = isdirectory,
    }

    filter_func.files = filter_func.file
    filter_func.dirs = filter_func.dir

    if filter_func[filter] ~= nil then
        local filtered = {}

        for _,element in pairs(results) do
            if filter_func[filter](element) then
                filtered[#filtered + 1] = element
            end
        end

        results = filtered
    end

    return results
end

function M.get_files(expr)
    expr = expr == nil and {} or expr
    expr.type = 'file'
    return M.files.ls(expr)
end

function M.get_dirs(expr)
    expr = expr == nil and {} or expr
    expr.type = 'dirs'
    return M.files.ls(expr)
end

function M.read_json(filename)
    if not filereadable(filename) then
        return false
    end
    return nvim.fn.json_decode(nvim.fn.readfile(filename))
end

function M.normalize_path(path)
    if path:sub(1, 1) == '~' then
        path = nvim.fn.expand(path)
    end
    return path:gsub('\\','/')
end

function M.rename(old, new, bang)

    new = M.normalize_path(new)
    old = M.normalize_path(old)

    if not filereadable(new) or bang == 1 then

        if not filereadable(old) then
            nvim.ex.write(old)
        end

        if bufloaded(new) then
            nvim.ex['bwipeout!'](new)
        end

        if rename(old, new) == 0 then
            local cursor_pos = nvim.win.get_cursor(0)

            nvim.ex.edit(new)
            nvim.ex['bwipeout!'](old)

            nvim.win.set_cursor(0, cursor_pos)

            return true
        else
            nvim.echoerr('Failed to rename '..old)
        end
    elseif filereadable(new) then
        nvim.echoerr('File: '..new..' exists, use ! to override, it')
    end

    return false
end

function M.delete(target, bang)
    target = M.normalize_path(target)
    if filereadable(target) or bufloaded(target) then
        if filereadable(target) then
            if nvim.fn.delete(target) == -1 then
                nvim.echoerr('Failed to delete the file: '..target)
            end
        end
        if bufloaded(target) then
            local command = bang == 1 and 'bwipeout! ' or 'bdelete! '
            local ok, error_code = pcall(nvim.command, command..target)
            if not ok and error_code:match('Vim(.%w+.)\\?:E94') then
                nvim.echoerr('Failed to remove buffer '..target)
            end
        end
    elseif isdirectory(target) then
        local flag = bang == 1 and 'rf' or 'd'
        if nvim.fn.delete(target, flag) == -1 then
            nvim.echoerr('Failed to remove the directory: '..target)
        end
    else
        nvim.echoerr('Non removable target: '..target)
   end
end

function M.skeleton_filename(opts)

    if type(opts) ~= 'table' then
        opts = {opts}
    end

    local filename = nvim.fn.expand('%:t:r')
    local extension = nvim.fn.expand('%:e') ~= '' and nvim.fn.expand('%:e') or '*'
    local skeleton = ''

    local template = #opts > 0 and opts[1] or ''

    local skeletons_path = sys.base..'/skeletons/'

    local known_names = {
        ['*'] = { 'clang-format', 'clang-tidy' },
        py    = {'ycm_extra_conf'},
        json  = {'projections'},
        c     = {'main'},
        cpp   = {'main'},
    }

    if #template ~= 0 then
        skeleton = nvim.fn.fnameescape(skeletons_path .. template)
    else

        if known_names[extension] ~= nil then
            local names = known_names[extension]
            for _, name in pairs(names) do

                if string.find(filename, name, 1, true) ~= nil then

                    local template_file = skeletons_path..name

                    if filereadable(template_file) then
                        skeleton = nvim.fn.fnameescape(template_file)
                        break
                    elseif filereadable(template_file..'.'..extension) then
                        skeleton = nvim.fn.fnameescape(template_file..'.'..extension)
                        break
                    end

                end
            end
        end

        if #skeleton == 0 then
            skeleton = nvim.fn.fnameescape(skeletons_path..'/skeleton.'..extension)
        end

    end

    if filereadable(skeleton) then
        nvim.ex.keepalt('read '..skeleton)
        nvim.command('silent! %s/\\C%\\<NAME\\>/'..filename..'/e')
        nvim.fn.histdel('search', -1)
        nvim.command('silent! %s/\\C%\\<NAME\\ze_H\\(PP\\)\\?\\>/\\U'..filename..'/g')
        nvim.fn.histdel('search', -1)
        nvim.ex['bwipeout!']('skeleton')
        nvim.command('1delete_')
    end

end

function M.clean_file()
    local buftypes = {
        nofile = 1,
        help = 1,
        quickfix = 1,
        terminal = 1,
    }

    local filetypes = {
        bin = 1,
        log = 1,
        git = 1,
        man = 1,
        terminal = 1,
    }

    local buftype = nvim.bo.buftype
    local filetype = nvim.bo.filetype

    if not nvim.b.trim or buftypes[buftype] ~= nil or filetypes[filetype] ~= nil or filetype == '' then
        return false
    end

    local position = nvim.win_get_cursor(0)
    local search_reg = nvim.fn.getreg('/')

    nvim.command('%s/\\s\\+$//e')
    nvim.fn.histdel('search', -1)

    nvim.command('%s/\\(\\s\\+\\)┊/\\1 /ge')
    nvim.fn.histdel('search', -1)

    if sys.name ~= 'windows' then
        nvim.command('%s/\\r$//ge')
        nvim.fn.histdel('search', -1)
    end

    nvim.win_set_cursor(0, position)
    nvim.fn.setreg('/', search_reg)
end

return M
