local M = {}

function M.switch_source_header_splitcmd(bufnr, splitcmd, client_name)
    client_name = client_name or 'clangd'
    local method_name = 'textDocument/switchSourceHeader'
    splitcmd = splitcmd or 'edit'
    bufnr = bufnr or vim.api.nvim_get_current_buf()

    local lsp = vim.F.npcall(require, 'lspconfig')
    if lsp then
        bufnr = require('lspconfig').util.validate_bufnr(bufnr)
    end

    local params = vim.lsp.util.make_text_document_params(bufnr)
    local client = vim.lsp.get_clients({ name = client_name, bufnr = bufnr })[1]
    if not client then
        return false
    end
    -- client.request(method_name, params, function(err, result) end, bufnr)
    local candidate = client:request_sync(method_name, params, 1000, bufnr)
    if not candidate or type(candidate) == type '' or candidate.err or not candidate.result then
        return false
    end
    vim.cmd { cmd = splitcmd, args = { vim.uri_to_fname(candidate.result) } }
    return true
end

function M.symbol_info()
    local method_name = 'textDocument/symbolInfo'

    local bufnr = vim.api.nvim_get_current_buf()
    local clangd_client = vim.lsp.get_clients({ bufnr = bufnr, name = 'clangd' })[1]
    if not clangd_client or not clangd_client:supports_method(method_name) then
        return vim.notify('Clangd client not found', vim.log.levels.ERROR)
    end
    local win = vim.api.nvim_get_current_win()
    local params = vim.lsp.util.make_position_params(win, clangd_client.offset_encoding)
    clangd_client:request(method_name, params, function(err, result, _) --[[@as lsp.Handler]]
        if err or #result == 0 then
            -- Clangd always returns an error, there is not reason to parse it
            return
        end
        local container = string.format('container: %s', result[1].containerName) ---@type string
        local name = string.format('name: %s', result[1].name) ---@type string
        vim.lsp.util.open_floating_preview({ name, container }, '', {
            height = 2,
            width = math.max(string.len(name), string.len(container)),
            focusable = false,
            focus = false,
            border = 'single',
            title = 'Symbol Info',
        })
    end, bufnr)
end

return M
