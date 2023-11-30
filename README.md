# Dotvim files

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

This repo have my personal Neovim settings for latest stable and nightly, I have been collecting and tweaking
for a while, feel free to change anything to fit your needs. I try to test this configs in Windows, MacOS and Linux
although windows is still unstable from time to time

## Status


| Linux                                                                                                                                                                  | Window                                                                                                                                                                       | MacOS                                                                                                                                                                  |
| -----------------------------------------------------------------------------------------------------------------------------------------------------------------      | -----------------------------------------------------------------------------------------------------------------------------------------------------------------------      | -----------------------------------------------------------------------------------------------------------------------------------------------------------------      |
| [![linux-stable](https://github.com/mike325/nvim/actions/workflows/linux_stable.yml/badge.svg)](https://github.com/mike325/nvim/actions/workflows/linux_stable.yml)    | [![windows-stable](https://github.com/mike325/nvim/actions/workflows/windows_stable.yml/badge.svg)](https://github.com/mike325/nvim/actions/workflows/windows_stable.yml)    | [![macos-stable](https://github.com/mike325/nvim/actions/workflows/macos_stable.yml/badge.svg)](https://github.com/mike325/nvim/actions/workflows/macos_stable.yml)    |
| [![linux-nightly](https://github.com/mike325/nvim/actions/workflows/linux_nightly.yml/badge.svg)](https://github.com/mike325/nvim/actions/workflows/linux_nightly.yml) | [![windows-nightly](https://github.com/mike325/nvim/actions/workflows/windows_nightly.yml/badge.svg)](https://github.com/mike325/nvim/actions/workflows/windows_nightly.yml) | [![macos-nightly](https://github.com/mike325/nvim/actions/workflows/macos_nightly.yml/badge.svg)](https://github.com/mike325/nvim/actions/workflows/macos_nightly.yml) |

## Install

If you are using [Neovim](https://neovim.io/) you just need to just clone the repo to `~/.config/nvim`

```sh
git clone --recursive https://github.com/mike325/nvim.git ~/.config/nvim/
```

To use Neovim in Windows clone the repo in the following location `$env:USERPROFILE/AppData/Local/nvim/`

```sh
git clone --recursive "https://github.com/mike325/nvim.git" "$env:USERPROFILE/AppData/Local/nvim/"
```

Feel free to change anything to fit your needs!

## Development

To execute the available test just run `make` on Linux/macOS or `./test/test.ps1` on windows

---
If you want to check my old Vim/Neovim compatible settings please check the legacy branch
