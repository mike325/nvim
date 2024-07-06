# Dotvim files

[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)

This repo have my personal Vim settings for latest stable and nightly, I have been collecting and tweaking
for a while, feel free to change anything to fit your needs. I try to test this configs in Windows, MacOS and Linux
although windows is still unstable from time to time

This repo have mi personal Vim settings that I have been collecting
for a while, feel free to change anything to fit your needs or suggest me
something that you think could be useful.

Since I use Vim in quite different environments my settings tries to get
the same behavior, as much as possible, for most of the cases.

This settings require Vim >= 7.4* ,
**python** and **lua** support are optional **but** highly recommend!

I have personally tested this configurations in the following environment:

| Linux        | Terminal vim  | gVim |
|--------------|---------------|------|
| Ubuntu 20.04 | v8.0          | N/A  |
| Ubuntu 22.04 | v9.0          | N/A  |
| Debian 12    | v8.0          | N/A  |
| RHLE   7/8   | v9.0          | N/A  |
| ArchLinux    | v9.0          | N/A  |

| Windows 10/11    | Terminal vim | gVim  |
|------------------|--------------|-------|
| Cywing           | v9.0         | N/A   |
| Git bash (msys)  | v9.0         | N/A   |
| Native (64 bits) | N/A          | v9.0  |

**Note**: Even though I have made some limited test with Vim 7.3 they have been
mostly simple editions, the recommend Vim version is still 7.4

**Note 2**: This is a branch from forked from my old legacy branch, which means this branch will not
be updated as much as `master` but it keeps compatibility with vim in more regards

## Status

| Linux                                                                                                                                                                             | Window                                                                                                                                                                       | MacOS                                                                                                                                                                  |
| -----------------------------------------------------------------------------------------------------------------------------------------------------------------                 | -----------------------------------------------------------------------------------------------------------------------------------------------------------------------      | -----------------------------------------------------------------------------------------------------------------------------------------------------------------      |
| [![linux-stable](https://github.com/mike325/nvim/actions/workflows/linux_stable.yml/badge.svg?branch=vim)](https://github.com/mike325/nvim/actions/workflows/linux_stable.yml)    | [![windows-stable](https://github.com/mike325/nvim/actions/workflows/windows_stable.yml/badge.svg?branch=vim)](https://github.com/mike325/nvim/actions/workflows/windows_stable.yml)    | [![macos-stable](https://github.com/mike325/nvim/actions/workflows/macos_stable.yml/badge.svg?branch=vim)](https://github.com/mike325/nvim/actions/workflows/macos_stable.yml)    |
| [![linux-nightly](https://github.com/mike325/nvim/actions/workflows/linux_nightly.yml/badge.svg?branch=vim)](https://github.com/mike325/nvim/actions/workflows/linux_nightly.yml) | [![windows-nightly](https://github.com/mike325/nvim/actions/workflows/windows_nightly.yml/badge.svg?branch=vim)](https://github.com/mike325/nvim/actions/workflows/windows_nightly.yml) | [![macos-nightly](https://github.com/mike325/nvim/actions/workflows/macos_nightly.yml/badge.svg?branch=vim)](https://github.com/mike325/nvim/actions/workflows/macos_nightly.yml) |

## Install

If you are using [vim](https://github.com/vim/vim) you just need to just clone the repo to `~/.vim`

```sh
git clone --branch=vim --recursive https://github.com/mike325/nvim.git ~/.vim
```

To use the dotfiles in Windows clone the repo in the following location `$env:USERPROFILE/vimfiles`

```sh
git clone --branch=vim --recursive "https://github.com/mike325/nvim.git" "$env:USERPROFILE/vimfiles"
```

Feel free to change anything to fit your needs!
