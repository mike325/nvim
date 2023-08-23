vim.paste = (function(overridden)
    return function(lines, phase)
        for i, line in ipairs(lines) do
            -- Scrub ANSI color codes from paste input.
            lines[i] = line:gsub('\27%[[0-9;mK]+', '')
            -- TODO: re-indent files to match current level and file indent
        end
        overridden(lines, phase)
    end
end)(vim.paste)
