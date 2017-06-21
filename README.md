---

This repo have mi personal Vim/Neovim settings that I have been collecting
for a while, feel free to change anything to fit your needs or suggest me
something that you think could be useful.

Since I use Vim in quite different environments my settings tries to get
the same behavior, as much as possible, for most of the cases.

This settings require Vim >= 7.4* or Neovim >= 0.17,
**python** and **lua** support are optional **but** highly recommend!

I have personally tested this configurations in the following environment:

| Linux            | Terminal vim       | gVim     | Terminal Neovim |
|------------------|--------------------|----------|-----------------|
| Ubuntu 14.04     | v7.4.52            | N/A      | v0.17           |
| Ubuntu 16.04     | v7.4.52            | N/A      | v0.17           |
| Debian 8/8.5     | v7.4.143           | N/A      | v0.17           |
| SUSE 11          | v8.0.104 and v7.3* | N/A      | v0.17           |
| ArchLinux        | v8.0.427           | N/A      | v0.17           |

| Android          | Terminal vim | gVim     | Terminal Neovim |
|------------------|--------------|----------|-----------------|
| Marshmallow      | v8.0.104     | N/A      | v0.2-dev        |
| Nougat           | v8.0.104     | N/A      | v0.2-dev        |

| Windows 8.1      | Terminal vim | gVim     | Terminal Neovim |
|------------------|--------------|----------|-----------------|
| Cywing           | v7.4.143     | N/A      | N/A             |
| Git bash (msys)  | v7.4.143     | N/A      | N/A             |
| Native (64 bits) | N/A          | v8.0.398 | N/A             |


**Note**: Even though I have made some limited test with Vim 7.3 they have been
mostly simple editions, the recommend Vim version is still 7.4 or Neovim 0.17

**Note 2**: I have not use this settings on a Mac, because I don't have one, feel
free to use my vim files and tell me if they worked for you.

## Install
---

You can test my settings by cloning this repo into your `$HOME`

```sh
git clone --recursive https://github.com/mike325/.vim.git ~/.vim

ln -s ~/.vim/init.vim ~/.vimrc
```

If you are using gVim in Windows you may want to use the following procedure:
(inside git bash)
```sh
git clone --recursive https://github.com/mike325/.vim.git ~/vimfiles

cp ~/vimfiles/init.vim ~/_vimrc
```

If you are using [Neovim](https://neovim.io/) you just need to link the repo
to `~/.config/nvim`

```sh
ln -s $HOME/.vim $HOME/.config/nvim
```

or just clone it there

```sh
git clone --recursive https://github.com/mike325/.vim.git ~/.config/nvim
```

To use Neovim in Windows (highly unstable and not well tested) clone the repo
in the following location

```sh
git clone --recursive https://github.com/mike325/.vim.git ~/AppData/Local/nvim/
```
Once you have cloned the repo just run `:PlugInstall` inside Vim/Neovim to
complete the installation process or start (n)vim as `vim +PlugInstall`

If you want to deactivate some plugins just comment its line in the init.vim, ex.
`" Plug 'majutsushi/tagbar'`, since most of the plugins settings are load only when
they are in the vim's runtimepath it will be deactivated in the next start;
you also want you remove the plugin's folder just run `:PlugClean` after you restart
(n)vim.

Feel free to change anything to fit your needs!
