# cebrusfs's dotfiles

## Issues

* Neovim Mason can't install clangd on ARM because clangd does not publish prebuilt binaries for every ARM target. Install clangd from the OS package manager when Mason fails.
   * https://github.com/mason-org/mason.nvim/issues/1578
   * https://github.com/clangd/clangd/issues/514
* Mouse scroll not smooth.
   * Vim: good
   * other pager: slow
   * over tmux?

### TODOs

* Migrate to Neovim built-in package management system (nvim 0.12+, not available in common Linux yet)
* Terminal migration: keep iTerm2 for `tmux -CC`; pilot Ghostty only for local shells/plain tmux before adding Brewfile/dotbot config. Research: [docs/terminal-migration.md](docs/terminal-migration.md)
* Shell migration: pilot fish manually before `chsh`; package/default-shell changes and shared fish syntax checks still need review. Research: [docs/shell-migration.md](docs/shell-migration.md)

## Agent Config

`config/agent/` is the source of truth for shared agent guidance and skills.
Tool-specific home directories are only adapters:

| Path | Purpose |
|---|---|
| `config/agent/global.md` | Shared durable guidance for personal and corp-safe use |
| `config/agent/claude/` | Claude-only settings and hook wiring |
| `config/agent/codex/` | Codex-only hooks, rules, and stable config template |
| `config/agent/skills/` | Shared Agent Skills source |
| `~/.claude/skills` | Claude skill adapter |
| `~/.agents/skills` | User-level Agent Skills adapter for Codex and Gemini CLI |

`config/agent/codex/config.toml` is a safe template, not a symlink target for
`~/.codex/config.toml`. Keep personal, runtime, and project trust state in the
local Codex config. If copying the template's permission profile into local
Codex config, do not mix it with legacy `sandbox_mode` /
`[sandbox_workspace_write]` settings; use one sandbox configuration model per
session.

Sync stable Codex defaults into the local runtime config with:

```sh
uv run --no-project --managed-python --python cpython python config/agent/codex/sync-config.py --apply
```

`./install` runs this sync after installing dev tools, and `./update` runs it
after updating dev tools.

The script preserves local runtime sections such as `[projects]`, `[hooks.state]`,
`[marketplaces]`, `[plugins]`, `[mcp_servers]`, and `[desktop]`, and strips the
legacy sandbox keys managed by the template.

Shared Codex execpolicy rules live in `config/agent/codex/rules/agent.rules`,
which dotbot links to `~/.codex/rules/agent.rules`. Keep
`~/.codex/rules/default.rules` as Codex's local mutable allow-list state.

The default Codex posture is `approval_policy = "on-request"`,
`approvals_reviewer = "auto_review"`, and `default_permissions =
"workspace-mise"`. The `workspace-mise` profile is the built-in workspace
filesystem sandbox plus a writable `mise` cache. It also grants scoped shell
network access to `api.github.com` and `github.com`, so sandboxed read-only
GitHub CLI inspection can work without broad network access. `web_search =
"live"` controls the agent's web-search tool, not network access for spawned
CLI commands such as `gh`.

Do not put custom user skills under `~/.codex/skills`; Codex keeps its own state,
cache, and bundled system skills there.

## Architecture (5-Phase)

The `./install` script executes a clean 5-phase bootstrap process:
- **Phase 1: Dotbot Init & Symlinks**: Initialize submodules and create dotfile symlinks.
- **Phase 2: OS Packages Setup**: Install system-level dependencies requiring root/sudo via `Brewfile.min` on macOS or batched `apt`/`dnf` on Linux.
- **Phase 3: Dev Tools & Binaries**: Bootstrap `mise`, install programming languages and tools (Rust, Node.js, Bun, Ruby, uv, rg, fd, fzf, delta), and sync stable Codex runtime defaults.
- **Phase 4: Vim Plugins**: Run PlugUpdate to install Vim/Neovim plugins automatically.
- **Phase 5: Shell Configuration**: Ensure Zsh is the default shell and cleanly transition the shell session.

## Package Management Strategy

To ensure cross-platform consistency while accommodating corp internal environment (gLinux) security requirements, packages are routed as follows:

| Package | Category | macOS | Personal Linux | gLinux (Corp) |
|---|---|---|---|---|
| **Mise** | Version Manager | Homebrew | Official `curl \| sh` | Official `curl \| sh` |
| **Zsh** | Shell | Built-in / Homebrew | `apt` / `dnf` | `apt` |
| **Vim** | Editor | Homebrew | `apt` / `dnf` | `apt` |
| **Neovim** | Editor | `mise` | `mise` | `mise` |
| **Rust / Node / Bun / Ruby / uv** | Language/toolchain | **Mise** | **Mise** | **Mise** |
| **Ripgrep / fd / fzf** | CLI Tools | **Mise** | **Mise** | **Mise** |
| **git-delta** | CLI Tools | **Mise** | **Mise** | **Mise** |
| **Jujutsu (jj)** | VCS Tool | Homebrew | **Mise** | Corp/system package |
| **Tmux / Git** | Core Tools | Homebrew | `apt` / `dnf` | Corp/system package |

### Design Decisions & Best Practices

**1. Tooling Isolation (Corp Compatibility)**
To prevent `mise` from overriding corp internal variants of tools (like `jj` and `git` which have specific SSO/credential hooks), we decouple them from the global `config/mise/config.toml`. Instead, they are placed in `config/mise/config.linux.local.toml`. The `dotbot.conf.yaml` strictly conditionally symlinks this local config *only* on non-gLinux environments. This guarantees Corp machines will never accidentally use the open-source variants.

**2. Editor Strategy (Vim vs Neovim)**
Vim is installed via native package managers (`apt`, `brew`) to guarantee ubiquitous availability as a fundamental fallback editor on any system. Neovim, however, is fully managed by `mise` to ensure the latest version is consistently available everywhere. Modern Lua plugins and LSP configurations heavily depend on recent Neovim features (0.10+) that are unavailable in outdated Linux package repositories.

**3. Script Execution Flow (Sourcing in Place)**
The `./install` script employs a strictly linear bootstrap process. Instead of interrupting the flow with an `exec zsh -c` to evaluate new tools, it uses `eval "$(mise activate bash)"` and `eval "$(/opt/homebrew/bin/brew shellenv)"` directly in the active Bash session. The script only commits to an `exec zsh -l` at the absolute very end of the execution (Phase 5). This prevents unpredictable subshell loops and ensures idempotency.

## INSTALL

```sh
bash <(curl -s https://raw.githubusercontent.com/cebrusfs/dotfiles/main/fetch)
p10k configure
```

### Post install (macOS)

#### Homebrew

```sh
brew bundle install -v --no-lock --file="homebrew/Brewfile.home"
```


## Key binding

* Terminator / iTerm2: Not using window splitting

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
