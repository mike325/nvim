# Dotvim files

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

## Nightly info
Welcome to the Nightly branch of my neovim configs, here I make some experiments,
migrate and refactor stuff to make it work with the latest Neovim version. This
branch may not work with stable branches.

---

This repo have my personal Neovim >= 0.5 settings that I have been collecting and tweaking
for a while, feel free to change anything to fit your needs. I try to test this configs in Windows, MacOS and Linux
tho windows is is still unstable in regarding some plugin integrations.

## Status
[![Linux Neovim Stable](https://github.com/Mike325/.vim/workflows/linux-stable/badge.svg)](https://github.com/Mike325/.vim/actions/workflows/linux_stable.yml)
[![Linux Neovim Nightly](https://github.com/Mike325/.vim/workflows/linux-nightly/badge.svg)](https://github.com/Mike325/.vim/actions/workflows/linux_nightly.yml)
[![macOS Neovim Stable](https://github.com/Mike325/.vim/workflows/macos-stable/badge.svg)](https://github.com/Mike325/.vim/actions/workflows/macos_stable.yml)
[![macOS Neovim Nightly](https://github.com/Mike325/.vim/workflows/macos-nightly/badge.svg)](https://github.com/Mike325/.vim/actions/workflows/macos_nightly.yml)
[![Windows Neovim Stable](https://github.com/Mike325/.vim/workflows/windows-stable/badge.svg)](https://github.com/Mike325/.vim/actions/workflows/windows_stable.yml)
[![Windows Neovim Nightly](https://github.com/Mike325/.vim/workflows/windows-nightly/badge.svg)](https://github.com/Mike325/.vim/actions/workflows/windows_nightly.yml)

## Install

If you are using [Neovim](https://neovim.io/) you just need to just clone the repo to `~/.config/nvim`

```sh
git clone --recursive https://github.com/mike325/.vim.git ~/.config/nvim/
```

To use Neovim in Windows clone the repo in the following location `$env:USERPROFILE/AppData/Local/nvim/`

```sh
git clone --recursive "https://github.com/mike325/.vim.git" "$env:USERPROFILE/AppData/Local/nvim/"
```

Feel free to change anything to fit your needs!

## Development

To execute the available test just run `make` on Linux/macOS or `./test/test.ps1` on windows

---
If you want to check my old Vim/Neovim compatible settings please check the legacy branch
