# cebrusfs's dotfiles

Personal dotfiles for macOS and Linux (incl. corp gLinux), managed by
[dotbot](https://github.com/anishathalye/dotbot) + **jj** + **mise**.

## Commands

```sh
# Fresh install (remote bootstrap)
bash <(curl -s https://raw.githubusercontent.com/cebrusfs/dotfiles/main/fetch)
p10k configure

# Pull updates + refresh submodules + update vim plugins
./update

# Re-create symlinks only (no package installs)
bin/dotbot -d . -c install-conf/dotbot.conf.yaml

# Install Homebrew packages (macOS) — pick the context
brew bundle install -v --no-lock --file="homebrew/Brewfile.home"   # personal
brew bundle install -v --no-lock --file="homebrew/Brewfile.work"   # work
brew bundle install -v --no-lock --file="homebrew/Brewfile.min"    # minimal/server
brew bundle install -v --no-lock --file="homebrew/Brewfile.ctf"    # CTF/security
```

## Where things live

| Path | Purpose |
|---|---|
| `config/<tool>/` | Tool configs, symlinked into `~` (zsh, fish, vim, git, jj, tmux, ssh, mise, agent, …) |
| `install-conf/dotbot.conf.yaml` | Source of truth for all symlink mappings |
| `homebrew/Brewfile.*` | Brewfiles per context (home / work / min / ctf) |
| `bin/` | Helper scripts (`bin/osx` is macOS-only) |
| `install`, `update` | Bootstrap and refresh entry points |
| `docs/` | Deep-dive notes (package routing, agent config, migrations) |

## Key Bindings

- Terminator / iTerm2: not using window splitting (delegated to tmux).

### Tmux

Ref: [`config/tmux/tmux.conf`](./config/tmux/tmux.conf)

- `Ctrl+A` as tmux prefix.

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

### Vim / Neovim

#### Leader Key
- `<Space>` is set as the leader key.

#### General & Navigation
| Action                     | Key                       | Description                                  |
|----------------------------|---------------------------|----------------------------------------------|
| Quick save                 | `<Space>w`                | Save current buffer (`:w`)                   |
| Quick reload               | `<Space>e`                | Reload current buffer (`:e`)                 |
| Move across wrapped lines  | `<Up>` / `<Down>`         | Move visually up/down even if lines wrap     |
| Copy to clipboard (remote) | `Y` (Visual)              | Copy via OSC52 (works over SSH/tmux)         |
| Trigger Easymotion         | `<Space><Space> + motion` | Quickly jump to specific targets             |

#### File Explorer (NERDTree)
| Action           | Key       | Description         |
|------------------|-----------|---------------------|
| Toggle directory | `<S-Tab>` | Open/close NERDTree |

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

## Known Issues / TODO

- Neovim Mason can't install clangd on ARM — clangd does not publish prebuilt
  binaries for every ARM target. Install clangd from the OS package manager when
  Mason fails.
  ([mason#1578](https://github.com/mason-org/mason.nvim/issues/1578),
  [clangd#514](https://github.com/clangd/clangd/issues/514))
- Mouse scroll not smooth: fine in Vim, slow in other pagers — possibly a tmux
  interaction.

## More

- [docs/package-management.md](docs/package-management.md) — install flow & per-platform package routing
- [docs/agent-config.md](docs/agent-config.md) — shared AI agent (Claude/Codex) config
- Research notes: [shell migration](docs/shell-migration.md),
  [terminal migration](docs/terminal-migration.md),
  [nvim plugin review](docs/nvim-plugin-review.md)
- Editing this repo with an AI agent? See [AGENTS.md](AGENTS.md).
