# cebrusfs's dotfiles

## Issues

* Neovim lsp plugins only support 0.11+. Even latest Ubuntu 25.10 don't have it
   ```
   sudo add-apt-repository ppa:neovim-ppa/unstable
   sudo apt update
   ```
* Neovim Mason can't install clangd on ARM as they don't have prebuild.
   * https://github.com/mason-org/mason.nvim/issues/1578
   * https://github.com/clangd/clangd/issues/514
* Neovim doesn't work on clipboard sync (seems resolve?)
   * https://github.com/neovim/neovim/issues/1822
   * Maybe https://github.com/bfredl/nvim-miniyank
* Mouse scroll not smooth.
   * Vim: good
   * other pager: slow
   * over tmux?

### TODOs

* Migrated to neovim built-in package management system
* Fix linux setup scripts for new deps
* Mise setup for languages env


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
| Action       | Key            | Description        |
|--------------|----------------|--------------------|
| New tab      | `<C-t>n`       | Create new tab     |
| Previous tab | `<C-t><Left>`  | Go to previous tab |
| Next tab     | `<C-t><Right>` | Go to next tab     |

#### Split Control
| Action           | Key           | Description         |
|------------------|---------------|---------------------|
| Vertical split   | `:vsp`        | Split vertically    |
| Horizontal split | `:sp`         | Split horizontally  |
| Move between     | `C-w <arrow>` | Move between splits |

#### Autocompletion (Neovim nvim-cmp)

Neovim uses nvim-cmp for intelligent autocompletion with multiple sources:

| Action             | Key         | Description                      |
|--------------------|-------------|----------------------------------|
| Trigger completion | `<C-Space>` | Show completion menu             |
| Scroll up docs     | `<C-b>`     | Scroll documentation up          |
| Scroll down docs   | `<C-f>`     | Scroll documentation down        |
| Abort completion   | `<C-e>`     | Close completion menu            |
| Confirm selection  | `<CR>`      | Accept selected completion item  |

#### Code Navigation (Neovim LSP Defaults)

Neovim provides these built-in LSP keybindings (no custom config needed):

| Action                 | Key        | Description                      |
|------------------------|------------|----------------------------------|
| Code action            | `gra`      | Code action (Normal & Visual)    |
| Go to implementation   | `gri`      | Go to implementation             |
| Rename symbol          | `grn`      | Rename symbol                    |
| Find references        | `grr`      | Find all references              |
| Go to type definition  | `grt`      | Go to type definition            |
| Document symbol        | `gO`       | List document symbols            |
| Show documentation     | `K`        | Show documentation in preview    |
| Signature help         | `<C-S>`    | Show signature help (Insert)     |

#### Search and Navigation (fzf-lua)

| Action                 | Key               | Description                        |
|------------------------|-------------------|------------------------------------|
| Find files             | `<Space>fo`       | Find files in project              |
| Project grep           | `<Space>r`        | Search in project files            |
| Project grep word      | `<Space><Space>r` | Search current word in project     |
| Search in buffer       | `<Space>/`        | Fuzzy find in current buffer       |
| Search in all buffers  | `<Space>.`        | Search in open buffers             |
| Help tags              | `<Space>fh`       | Search help tags                   |

#### Git Integration (vim-fugitive)
| Action        | Key         | Description        |
|---------------|-------------|--------------------|
| Git status    | `<Space>gs` | Show git status    |
| Git diff      | `<Space>gd` | Show git diff      |
| Git blame     | `<Space>gb` | Show git blame     |
| Git mergetool | `<Space>gm` | Open git mergetool |

#### Diagnostics (Neovim LSP Defaults)
Neovim with LSP provides these built-in diagnostic navigation keybindings:

| Action              | Key      | Description                  |
|---------------------|----------|------------------------------|
| Previous diagnostic | `[d`     | Jump to previous diagnostic  |
| Next diagnostic     | `]d`     | Jump to next diagnostic      |
| First diagnostic    | `[D`     | Jump to first diagnostic     |
| Last diagnostic     | `]D`     | Jump to last diagnostic      |
| Show diagnostic     | `<C-w>d` | Show diagnostic in float     |

#### Comments

| Action         | Key | Description                  |
|----------------|-----|------------------------------|
| Toggle comment | `\` | Toggle comment for selection |

#### Alignment

| Action     | Key        | Description           |
|------------|------------|-----------------------|
| Easy align | `<Space>-` | Interactive alignment |

#### Language-specific
| Action        | Key        | Description                                             |
|---------------|------------|---------------------------------------------------------|
| Run program   | `<Space>p` | Run file (C/C++, Go, JS, Python, Ruby, Shell, Rust)     |
| Check program | `<Space>c` | Check/compile (C/C++, Rust)                             |
