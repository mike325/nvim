# Dotvim files

[![Github Status](https://github.com/Mike325/.vim/workflows/neovimfiles/badge.svg)](https://github.com/Mike325/.vim/actions)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

---

This repo have my personal Neovim >= 0.5 settings that I have been collecting and tweaking
for a while, feel free to change anything to fit your needs. I try to test this configs in Windows, MacOS and Linux
tho windows is is still unstable in regarding some plugin integrations.

## Install

---

If you are using [Neovim](https://neovim.io/) you just need to just clone the repo to `~/.config/nvim`

```sh
git clone --recursive https://github.com/mike325/.vim.git ~/.config/nvim/
```

To use Neovim in Windows clone the repo in the following location

```sh
git clone --recursive https://github.com/mike325/.vim.git ~/AppData/Local/nvim/
```

Feel free to change anything to fit your needs!

---
Development

To execute the available test just run `make` on Linux/macOS or ./test/test.ps1 on windows

---

If you want to check my old Vim/Neovim compatible settings please check the legacy branch
