local executable = require('utils.files').executable

if executable 'cmake' then
    RELOAD('filetypes.cmake').setup()
end
