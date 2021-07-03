local executable = require'utils.files'.executable

if executable('cmake') then
    require'filetypes.cmake'.setup()
end

