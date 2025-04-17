local M = {}

function M.send_osc1337(name, val)
    local b64 = vim.base64.encode(val)
    local seq = vim.env.TMUX and '\x1bPtmux;\x1b\x1b]1337;SetUserVar=%s=%s\b\x1b\\' or '\x1b]1337;SetUserVar=%s=%s\b'
    local stdout = vim.uv.new_tty(1, false)
    stdout:write(seq:format(name, b64))
end

function M.send_osc52(lines)
    local b64 = vim.base64.encode(table.concat(lines, '\n'))
    local seq = vim.env.TMUX and '\x1bPtmux;\x1b\x1b]52;;%s\b\x1b\\' or '\x1b]52;;%s\x1b\\'
    local stdout = vim.uv.new_tty(1, false)
    stdout:write(seq:format(b64))
end

return M
