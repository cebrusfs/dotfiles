# cebrusfs's dotfiles

## Issues

* https://github.com/neovim/neovim/issues/1822
   * Maybe https://github.com/bfredl/nvim-miniyank

## TODOs
* Fill key mappings

## INSTALL

```sh
bash <(curl -s https://raw.githubusercontent.com/cebrusfs/dotfiles/main/fetch)
p10k configure
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



### Vim Key Mappings

#### Leader Key
- `<Space>` is set as the leader key

#### Tab Control
| Action          | Key            | Description       |
|-----------------|----------------|-------------------|
| New tab         | `<C-t>n`       | Create new tab    |
| Previous tab    | `<C-t><Left>`  | Go to previous tab|
| Next tab        | `<C-t><Right>` | Go to next tab    |

#### Split Control
| Action          | Key            | Description       |
|-----------------|----------------|-------------------|
| Vertical split  | `:vsp`         | Split vertically  |
| Horizontal split| `:sp`          | Split horizontally|
| Move between    | `C-w <arrow>`  | Move between splits|

#### Code Navigation (CoC)
| Action               | Key            | Description                   |
|----------------------|----------------|-------------------------------|
| Go to definition     | `<Space>jd`    | Go to definition              |
| Go to type def       | `<Space>jt`    | Go to type definition         |
| Go to implementation | `<Space>ji`    | Go to implementation          |
| Go to references     | `<Space>jr`    | Find references               |
| Show documentation   | `K`            | Show documentation in preview |
| Rename symbol        | `<Space>rn`    | Rename symbol                 |
| Format code          | `<Space>=`     | Format selected code          |
| Code action          | `<Space>a`     | Show code actions             |
| Code action cursor   | `<Space>ac`    | Show code actions at cursor   |
| Code action buffer   | `<Space>as`    | Show code actions for buffer  |
| Quick fix            | `<Space>qf`    | Apply quick fix               |
| Refactor             | `<Space>re`    | Show refactor options         |
| Code lens            | `<Space>cl`    | Run code lens action          |

#### Search and Navigation
| Action                    | Key                | Description                    |
|--------------------------|-------------------|-------------------------------|
| Search in buffer         | `<Space>/`        | Search in current buffer      |
| Search word in buffer    | `<Space><Space>/` | Search current word in buffer |
| Search in all buffers    | `<Space>.`        | Search in all open buffers    |
| Search word in buffers   | `<Space><Space>.` | Search current word in buffers|
| Project grep             | `<Space>r`        | Search in project files       |
| Project grep word        | `<Space><Space>r` | Search current word in project|
| Find files              | `<Space>fo`       | Find files in project         |
| List directories        | `<Space>fls`      | List directories              |

#### Git Integration
| Action              | Key            | Description                    |
|--------------------|----------------|-------------------------------|
| Git status         | `<Space>gs`    | Show git status               |
| Git diff           | `<Space>gd`    | Show git diff                 |
| Git blame          | `<Space>gb`    | Show git blame                |
| Git mergetool      | `<Space>gm`    | Open git mergetool            |
| Git actions        | `<Space>ga`    | Show git actions              |
| Previous conflict  | `[g`           | Go to previous git conflict   |
| Next conflict      | `]g`           | Go to next git conflict       |
| Show commit        | `<Space>gbc`   | Show commit at current pos    |

#### Diagnostics
| Action              | Key            | Description                    |
|--------------------|----------------|-------------------------------|
| Previous diagnostic| `[d`           | Go to previous diagnostic     |
| Next diagnostic    | `]d`           | Go to next diagnostic         |
| Show diagnostics   | `<Space>a`     | Show all diagnostics          |
| Show commands      | `<Space>c`     | Show available commands       |
| Show outline       | `<Space>o`     | Show file outline             |
| Show symbols       | `<Space>s`     | Search workspace symbols      |

#### Comments
| Action          | Key    | Description                    |
|----------------|--------|-------------------------------|
| Toggle comment | `\`    | Toggle comment for line/selection|

#### Alignment
| Action          | Key         | Description                    |
|----------------|-------------|-------------------------------|
| Easy align     | `<Space>-`  | Start interactive alignment   |

#### Language-specific
| Action          | Key         | Description                    |
|----------------|-------------|-------------------------------|
| Run program    | `<Space>p`  | Run current file (C/C++, Go, JavaScript, Python, Ruby, Shell, Rust) |
| Check program  | `<Space>c`  | Check/compile current file (C/C++, Rust) |
