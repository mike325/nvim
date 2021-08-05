-- vim: ft=lua tw=80

-- Rerun tests only if their modification time changed.
std = 'luajit'
cache = true

ignore = {
    "212", -- Unused argument
}

read_globals = {
    "packer_plugins",
    "bit",
    "vim",
    "nvim",
    "python",
    "P",
    "RELOAD",
    "PASTE",
    "STORAGE",
    "use",
    "use_rocks",
}
