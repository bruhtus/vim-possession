# possession.vim

Possession is a flexible vim session management plugin. By default, possession save the vim session file to external directory so that vim session file did not clutter your project directory. Possession can also move the current vim session file into current working directory if you want to bring your vim session file along with you.

Possession save the vim session whether in external directory (which is possession directory, see [customization section](#customization) for more info) or current working directory with `Session.vim` as file name after you (purposely) exit vim. See [usage section](#usage) for more info.

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

Use `:Possess` command to start tracking vim session. If it's already tracking vim session and you use `:Possess` command again, it will pause tracking vim session. You need to enable it again by using `:Possess` command again. Use `:Possess!` command to remove current vim session.

Use `:PLoad` to load vim session. By default, `:PLoad` command will load `Session.vim` file in current working directory first. If `Session.vim` file in current working directory not found, `:PLoad` command will load vim session according to the path, git root repo, and git branch.

Use `:PList` command to check the available vim session. The output pattern is like this:
```sh
/<vim-session-for-directory>/<git-branch>
```

> Please note that `:PList` command only list the vim session under possession directory.

Use `:PMove` command to move the current vim session file. Here's the scenario of what will `:PMove` command do:
- If the current vim session file under possession directory exist and the `Session.vim` under current working directory doesn't exist, `:PMove` command will move the current vim session file to current working directory according to possession git root setting with the name `Session.vim`.
- If the current vim session file under current working directory with the name `Session.vim` exist and the vim session file under possession directory doesn't exist, `:PMove` command will move the current vim session file to possession directory according to possession git root and git branch setting for the file name.
- If both `Session.vim` in current working directory and vim session file in possession directory exist, there will be a confirmation dialog to choose whether to replace it or not. Move vim session file from current working directory to possession directory or from possession directory to current working directory.

By default, possession remove the alternate buffer if the file doesn't exists. It's because default vim session options use the directory of the last active file and opened the file relative to these directory which usually result in vim open a file that doesn't exist as alternate buffer.

To make vim use absolute path when using vim session, you can remove `curdir` option from `sessionoptions` like this:
```vim
set sessionoptions-=curdir
```
for more info, you can check `:h 'sessionoptions'`.

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

By default, possession use git root repo directory name as base for vim session. If you open a file from the directory that is not a git repo, then possession will use current working directory from your terminal emulator. Basically possession use the directory name where you enter vim, not the current working directory of the last opened file.

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

### Statusline integration

To make possession as simple as possible, possession doesn't provide a feature to integrate with statusline. But, you can define a function for your statusline like this:
```vim
function! PossessionStatusline()
  return exists('g:current_possession') ? '[S]' : '[$]'
endfunction
```
it will show `[S]` if possession tracking the session and `[$]` if possession not tracking the session. And don't forget to integrate those function into your respective statusline.

## FAQ

- Why vim-possession save vim session based on git branch even though I disable git root repo directory?

> It's for someone that want to save vim session based on the current working directory instead of git root repo directory. This enable them to have multiple vim session in the same git repo directory. So, you need to disable both git root repo directory and git branch if you didn't want to use both git root repo directory and git branch.

## Inspired by

- [vim-obsession](https://github.com/tpope/vim-obsession).
- [vim-prosession](https://github.com/dhruvasagar/vim-prosession).
- [vim-startify](https://github.com/mhinz/vim-startify).
- [persistence.nvim](https://github.com/folke/persistence.nvim).
- [tpope's vimrc](https://github.com/tpope/tpope/blob/964a173278f9ef556e76d4e778347745fba92e0b/.vimrc#L493-L496).
