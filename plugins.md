# Plugins
---

Here are the plugin that are install once you run `:PlugInstall`

## Themes
---
Cool color schemes that I like to use, all the color scheme has
`set backgroud=dark` since I don't like white themes, Gruvbox is the default
theme. I map the following keys to quickly change the current color scheme.

* Normal mode:
    * `csg` activate Gruvbox color scheme
    * `csm` activate Monokai color scheme
    * `csj` activate Jellybeans color scheme
    * `csb` activate Gotham color scheme (B for Batman)
    * `cso` activate Onedark color scheme

**Note**: All color schemes maps have also have an associated Airline theme,
so using the mappings also set up an color theme for Airline.

**Note 2**: Currently there's a kind of *bug* that disable some colors once
you jump from different color schemes, I have to figured out what is that
happening.

#### Gruvbox
#### Monokai
#### Jellybeans
#### Gotham
#### Onedark

## File explorer
---
Normally I don't use the file explorer plugins but the come handy when you
really need them, that's why I keep them.

#### NERDTree
On of th best file explorers out there, I really didn't modify a lot of the
default behavior since I really don't use it a lot.
I set `NERDTreeIgnore` to ignore all files with the extensions
.pyc, ~, .sw and .swp.
I also set NERDTree to show the line numbers and the bookmarks by default.

Finally I create the following maps

* Normal mode
    * `T` toggles NERDTree
    * `<F3>` toggles NERDTree
* Visual and Select modes
    * `<F3>` Escape visual/select mode and toggles NERDTree
* Insert mode
    * `<F3>` Escape insert mode and toggles NERDTree

#### NERDTree git plugin
This shows the current Git status of the files and dirs in the NERDTree panel.
I actually did not modify anything of this plugin, I just add the default
characters of the web page

## Status bar
---
The status bar is a great place to get all kind of information at a glance!
I think that Airline accomplish that just flawlessly!

#### Airline
Airline is a simple-lightweight yet powerful and extensible status bar.
Airline is written in 100% vimscript with no outside dependencies.

I setup Airline with the settings:

* Enable Tabline by default
* Set Tabline to show just the filename instead of the full path
* Set the close simbole to 'x'
* Set Tabline to show tabs when they are available
* Set Tabline to show the available buffers when there's just one tab
* Disable close botton
* airline#extensions#tabline#show_splits       = 0
<!-- * airline_powerline_fonts = 1 -->

" let g:airline#extensions#tabline#show_tab_nr = 0

#### Airline themes
This are just the standard themes provided for Airline, I use the ones that
match the available color schemes.

#### Airline clock
This is a small plugin that shows the current hour, pretty useful when
(Neo/g)vim is being used in full screen mode.

## Git indentation
---
The git integration is important, so I activate a couple of plugins that I have
found useful.

#### Fugitive
Maybe the best git integration made for Vim ever. Fugitive works out of the box
I just create a couple of maps to speed the things a bit.

* Normal mode:
    * `<leader>gs` Launch git status
    * `<leader>gw` Launch Gwrite to stage the current changes of the buffer
    * `<leader>gr` Read the state of the buffer in the index and load it.
    * `<leader>gc` Launch a git commit showing the state of the repo
    * `<leader>gd` Shows the diff of the current buffer just like Git diff

#### Gitgutter
Gitgutter shows the diff in with little signs at side of the buffer, it also
it provide a nice functions and movements to manage the hunks.

I disable the default maps `let g:gitgutter_map_keys = 0` and replace them
with my own.

* Normal mode:
    * `tg` Toggle the Gitgutter plugin
    * `tl` Toggle the Line Highlights
    * `[h` Go to the previous hunk in the current buffer
    * `]h` Go to the next hunk in the current buffer
    * `<leader>ghs` Stage the hunk under the cursor
    * `<leader>ghu` Unstage the hunk under the cursor
    * `ih` Operates over the inner hunk
    * `ah` Operates over the outer hunk
* Visual mode:
    * `ih` Operates over the inner hunk
    * `ah` Operates over the outer hunk

#### Gitv
Gitv depends on Fugitive and can't work on its own, it's a vim version of
Gitk graphic client, It allow you to see the git log side by side with the
changes in each commit.

#### Committia
This plugin just works when a `git commit` command is launch from the cli.
It opens vim with three splits, showing the diff in the commit, the state of
the repo and letting you edit the commit message.

#### Vim-git
Vim git include syntax, indent, and filetype plugin files for git, gitcommit,
gitconfig, gitrebase, and gitsendemail.

## Motions
---

Default vim motions are already pretty powerful but there's always a bit of
space for improvements! I already mention some motions in the Git section
(The ones that operates with hunks).

#### Vim-textobj-user
Textobj allow anybody to define their own text objects that are usable to any
vim command and motion

#### Vim-textobj-line
Line text object uses textobj-user to operate over the line under the cursor,
it maps the text object to `il` (inside the line) and `al` (around the line)
in normal and visual mode.

Ex.
* `yil` to yank the current line without leading/trimming spaces
* `vil` to visually select the current line without leading/trimming spaces
* `yal` to yank the current line with leading/trimming spaces
* `dil` to delete the current line without leading/trimming spaces

#### Vim-textobj-comment
Comment text object uses textobj-user to operate over the comment under the
cursor, it maps the text object to `ic` (inside the comment),
`iC`, `aC`, `ac` in normal and visual mode.

Ex.
* `yic` to yank comment under the cursor without the comment characters
* `yac` to yank comment under the cursor with the comment characters
* `dac` delete the comment under the cursor, the content and the characters
* `cic` changes the content within the comment

#### Vim-textobj-xmlattr
Comment text object uses textobj-user to operate over the the attributes of
HTML/XML tags

#### Vim-indent-object
Indent text ( object does not depend on textobj plugin ) allow you to operate
on the indent level, it is extreme useful for languages that does not define
code limits with (), [] or {}, like python, bash, ruby, vimL, etc.
It maps the text object to `ii` (inside the indent level),
`ai` (indent level with one line above),
`aI` (indent level with one line above and one line below)
in normal and visual mode.

Ex.
* `yii` yanks the current indent level
* `yai` yanks the current indent level with one line above of the upper level (like def in python)
* `daI` deletes the current indent level with one line above and up and one line below of the upper level (like if in VimL)
* `cii` changes the content of the indent level

#### Vim-surround
Vim surround, as its name hints, help you surround things with the operator
`ys` and `cs` in normal mode and `S` in visual mode, so you can type any motion you like
to surround stuff with almost anything you want.

**Note**: it works with user define text object, like indent, comment and lines.

Ex.
* `ysiw'` to add '' to the word under the cursor
* `ysi)"` to add "" to anything inside ()
* `ysil)"` surround the current line with ()
* `cs'"` To change the surrounding '' with ""
* `V4jS}` to surround with {} 4 lines below the cursor

#### Vim-grepper
#### Vim-easymotion
#### Nerdcommenter

## Languages Syntax
---
Just some small improvements to the default syntax highlight of some file types.

#### Dockerfile.vim
Improve the syntax for Dockerfiles

#### vim-json
Improve the syntax for json files

#### vim-lua
Better syntax highlight for lua files

#### vim-cpp-enhanced-highlight
Some improvements for C++ files

#### vim-qml
Add Qml syntax highlight

## Completion engines
---


#### deoplete
Deoplete is install just when Neovim is running with python3 support
`pip3 install --user neovim`. It uses the Asynchronous framework
allowing to make completions extremely fast without blocking the user interface,
it can be easily extended with complementary plugin. I configure deoplete be enable
from the startup, it matches in the possible candidates in a full fuzzy way, ex.
`prt` will match `print` but `ptr` will not. If ultisnips is present the following
mappings will be apply:

* Insert mode:
    * <TAB> will check if the completion menu is open, if it's open then it will check if the current
        expression match any known snippet, if true it get expand, if false it move to the next
        occurrence in the menu, finally if the menu is not present, it will insert a tab.
    * <CR> will check if the completion menu is open, if it's open then it will insert the
        select completion and close the menu, if the menu is not open then it will check if
        the key is inside a snippet, if it's inside then it will jump to the next expantion
        region, finally if there's not snippet available it will inset a newline.

* Normal mode:
    * <CR> will check if the completion menu is open, if it's open then it will insert the
        select completion and close the menu, if the menu is not open then it will check if
        the key is inside a snippet, if it's inside then it will jump to the next expantion
        region, finally if there's not snippet available it will inset a newline.

```viml
let g:deoplete#enable_at_startup = 1

" Use smartcase.
let g:deoplete#enable_smart_case = 1
let g:deoplete#enable_refresh_always = 1

" Set minimum syntax keyword length.
let g:deoplete#sources#syntax#min_keyword_length = 1
let g:deoplete#lock_buffer_name_pattern = '\*ku\*'

if &runtimepath =~ 'ultisnips'
    inoremap <expr><TAB> pumvisible() ? "<C-R>=<SID>ExpandSnippetOrComplete()<CR>" : "\<TAB>"
    inoremap <expr><CR> pumvisible() ? "\<C-y>" : "\<C-R>=NextSnippetOrReturn()\<CR>"
    nnoremap <silent><CR>  :<C-R>=NextSnippetOrNothing()<CR>
    " vnoremap <CR> <ESC>:<C-R>=NextSnippetOrNothing() ? '': 'gv'<CR><CR>
else
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><CR> pumvisible() ? "\<C-y>" : "\<CR>"
endif

inoremap <expr><S-TAB>  pumvisible() ? "\<C-p>" : ""
inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"
inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  deoplete#mappings#smart_close_popup()
inoremap <expr><C-e>  deoplete#cancel_popup()

let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})

let g:deoplete#omni#input_patterns.java = ['[^. \t0-9]\.\w*']
let g:deoplete#omni#input_patterns.javascript = ['[^. \t0-9]\.\w*']
let g:deoplete#omni#input_patterns.python = ['[^. \t0-9]\.\w*']
let g:deoplete#omni#input_patterns.go = ['[^. \t0-9]\.\w*']

let g:deoplete#omni#input_patterns.c = [
            \'[^. \t0-9]\.\w*',
            \'[^. \t0-9]\->\w*',
            \'[^. \t0-9]\::\w*',
            \]

let g:deoplete#omni#input_patterns.cpp = [
            \'[^. \t0-9]\.\w*',
            \'[^. \t0-9]\->\w*',
            \'[^. \t0-9]\::\w*',
            \]

" let g:deoplete#sources._ = ['buffer', 'member', 'file', 'tags', 'ultisnips']
let g:deoplete#sources={}
let g:deoplete#sources._    = ['buffer', 'member', 'file', 'tags', 'ultisnips']

let g:deoplete#sources.vim        = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
let g:deoplete#sources.c          = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
let g:deoplete#sources.cpp        = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
let g:deoplete#sources.go         = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
let g:deoplete#sources.java       = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
let g:deoplete#sources.python     = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
let g:deoplete#sources.javascript = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
let g:deoplete#sources.ruby       = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']

" if !exists('g:deoplete#omni#input_patterns')
"     let g:deoplete#omni#input_patterns = {}
" endif

autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
call deoplete#custom#set('ultisnips', 'matchers', ['matcher_full_fuzzy'])
```

#### deoplete-jedi
#### deoplete-clang
#### deoplete-ternjs
#### deoplete-go
#### completor.vim
#### YouCompleteMe
#### neocomplete.vim
#### neocomplcache.vim

#### jedi-vim
#### delimitMate
#### python-mode
#### vim-go
#### vim-javacomplete2

## Syntax checker
---

#### syntastic
#### neomake

## Snippets
---

#### vim-addon-mw-utils
#### tlib_vim
#### vim-snipmate
#### ultisnips
#### vim-snippets

## Project base
---

#### vim-misc
#### vim-session
#### ctrlp.vim
#### ctrlp-py-matcher

## Visual improvements
---

#### tabular
#### hexmode
#### indentLine
#### vim-signature
#### vim-pasta
#### vimtex
#### tagbar
#### vim-autoformat

## Miscellanies
---

#### vim-bbye
#### vim-move
#### vim-abolish
#### vim-repeat
#### vim-windowswap
#### vim-eunuch
#### vim-sensible
#### ycm-generator
