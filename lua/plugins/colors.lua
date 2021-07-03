local load_module = require'utils.helpers'.load_module

local colorizer = load_module'colorizer'

if colorizer then
    vim.o.termguicolors = true
    colorizer.setup()
end

local colors = {
    white        = '#FFFFFF',
    black        = '#000000',
    cyan         = '#008080',
    blue         = '#0000D8',
    purple       = '#5D4D7A',
    pink         = '#D16D9E',
    orange       = '#FF8800',
    brown        = '#825A03',
    light_yellow = '#FAFF00',
    dark_yellow  = '#E0DF3F',
    light_green  = '#00C800',
    dark_green   = '#004800',
    light_gray   = '#404040',
    dark_gray    = '#282828',
    light_red    = '#E80000',
    dark_red     = '#480000',
}

return colors
