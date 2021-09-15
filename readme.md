# possession.vim

Possession is a plugin to save vim session without cluttering project directory. Possession also save the file according to git root repo directory and git branch, so you can have different vim session for different git branch.

## Installation

Install this plugin using your favorite plugin manager, below is a few example of plugin manager that available:
- [vim-plug](https://github.com/junegunn/vim-plug)
```vim
Plug 'bruhtus/vim-possession'
```
- [packer.nvim](https://github.com/wbthomason/packer.nvim)
```vim
use 'bruhtus/vim-possession'
```
- [minpac](https://github.com/k-takata/minpac)
```vim
call minpac#add('bruhtus/vim-possession')
```

## Usage

Use `:Possess` command to start tracking vim session. If it's already tracking vim session and you use `:Possess` command again, it will pause tracking vim session. You need to enable it again by using `:Possess` command again.

Use `:Possess!` to remove current vim session. Use `:PLoad` to load vim session according to the path, git root repo, and git branch.

## Customization

### Default directory

By default, possession save vim session file in:
- `~/.local/share/nvim/session` for neovim.
- `~/.vim/session` for vim.

You can change the default directory by set `g:possession_dir` like this:
```vim
" inside your vimrc or something similar
let g:possession_dir = '~/path/to/directory'
```
and remove those line if you want to use the default directory.

### Git root repo directory

By default, possession use git root repo directory name as base for vim session. If you open a file from the directory that is not a git repo, then possession will use current working directory from your terminal emulator. Basically possession use the directory name where you enter vim, not the current working directory of the last opened file you.

> To make things simple, git root repo directory is a directory that contains `.git` directory.

To disable this option, you can set `g:possession_no_git_root` like this:
```vim
" inside your vimrc or something similar
let g:possession_no_git_root = 1
```
and remove those line if you want to enable it again.

### Git branch

By default, possession use git repo branch name as base for vim session. This option enable you to have vim session for different git repo branch. To disable this option, you can set `g:possession_no_git_branch` like this:
```vim
" inside your vimrc or something similar
let g:possession_no_git_branch = 1
```
and remove those line if you want to enable it again.

## FAQ

- Why vim-possession save vim session based on git branch even though I disable git root repo directory?

> It's for someone that want to save vim session based on the current working directory instead of git root repo directory. This enable them to have multiple vim session in the same git repo directory. So, you need to disable both git root repo directory and git branch if you didn't want to use both git root repo directory and git branch.

## Inspired by

- [vim-obsession](https://github.com/tpope/vim-obsession).
- [vim-prosession](https://github.com/dhruvasagar/vim-prosession).
- [vim-startify](https://github.com/mhinz/vim-startify).
- [vim-persistence](https://github.com/folke/persistence.nvim).
- [tpope's vimrc](https://github.com/tpope/tpope/blob/964a173278f9ef556e76d4e778347745fba92e0b/.vimrc#L493-L496).
