# cebrusfs's dotfiles

## Issues

* https://github.com/neovim/neovim/issues/1822
   * Maybe https://github.com/bfredl/nvim-miniyank

## TODOs
* Install `homebrew` for OSX
* Install `python-minimal` `zsh` for linux
* Fill key mappings

## INSTALL

```sh
bash <(curl -s https://raw.githubusercontent.com/cebrusfs/dotfiles/main/fetch)
```

### Post install (OSX)

#### Homebrew

```sh
brew bundle install -v --no-lock --file="~/.dotfiles/homebrew/Brewfile.home"
```

#### Topcoder Client

```sh
DOTFILE_DIR=~/.dotfiles
ln -s "$DOTFILE_DIR/config/topcoder" "$HOME/Topcoder"
ln -s "$DOTFILE_DIR/config/topcoder/contestapplet.conf" "$HOME/contestapplet.conf"
chflags -h hidden "$HOME/contestapplet.conf"

touch "$HOME/contestapplet.conf.bak"
chflags -h hidden "$HOME/contestapplet.conf.bak"
```


## Key binding

* Terminator / iTerm2: Not using window spliting

### Tmux

Ref: [tmux.conf](./config/tmux/tmux.conf)

* `Ctrl+A` as tmux prefix

#### Windows (tabs)

|                     | Key | Default |
| ------------------- | --- | ------- |
| New window          |     | `c`     |
| Go last window      | `a` | `l`     |
| Go next window      |     | `n`     |
| Go previous window  |     | `p`     |
| list windows        |     | `w`     |
| find window         |     | `f`     |
| name the window     |     | `,`     |
| kill the window     |     | `&`     |

#### Panes (splits)

|                                                  | Key | Default     |
| ------------------------------------------------ | --- | ----------- |
| Move between splits                              |     | `<arrow>`   |
| show pane numbers (and jump if press the number) |     | `q`         |
| vertical split                                   | `s` | `%`         |
| horizontal split                                 | `v` | `"`         |
| kill current pane                                | `k` | `x`         |

### Vim tabs
TODO

### Vim Split
```
:vsp          vertical split
:sp           horizontal split
C-w <arrow> move between split
```
