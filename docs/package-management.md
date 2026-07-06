# Package Management & Install Flow

How packages are routed across platforms, why, and how `./install` bootstraps a
machine.

## Install Flow (5 phases)

`./install` runs a clean linear bootstrap:

1. **Dotbot Init & Symlinks** — initialize submodules and create dotfile symlinks.
2. **OS Packages** — install system-level dependencies requiring root/sudo via
   `Brewfile.min` on macOS, or batched `apt`/`dnf` on Linux.
3. **Dev Tools & Binaries** — bootstrap `mise`, install languages and CLI tools
   (Rust, Node.js, Bun, Ruby, uv, rg, fd, fzf, delta), and sync stable Codex and
   Antigravity CLI runtime defaults; see [Agent Config](agent-config.md#antigravity-cli-permissions) for its runtime-state preservation caveat.
4. **Editor Plugins** — Vim plugins install via `PlugUpdate`. Neovim installs
   missing `vim.pack` plugins at the tracked lock-file revisions
   (`config/nvim/nvim-pack-lock.json`) on normal startup; upgrades are
   intentional `vim.pack.update()` operations, and `config/vim/update` cleans
   plugins no longer declared.
5. **Shell Configuration** — ensure Zsh is the default shell and transition the
   session.

## Routing Table

To keep cross-platform consistency while respecting corp (gLinux) security
requirements, packages are routed as follows:

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

## Design Decisions

### Tooling Isolation (Corp Compatibility)
To prevent `mise` from overriding corp internal variants of tools (like `jj` and
`git`, which have specific SSO/credential hooks), they are decoupled from the
global `config/mise/config.toml` and placed in
`config/mise/config.linux.local.toml`. `dotbot.conf.yaml` conditionally symlinks
this local config *only* on non-gLinux environments, so corp machines never
accidentally use the open-source variants.

### Editor Strategy (Vim vs Neovim)
Vim is installed via native package managers (`apt`, `brew`) to guarantee a
ubiquitous fallback editor on any system. Neovim is fully managed by `mise` so
the latest version is consistently available — modern Lua plugins and LSP configs
depend on recent Neovim features (0.10+) absent from outdated Linux repos.

### Script Execution Flow (Sourcing in Place)
The `./install` script is strictly linear. Instead of interrupting the flow with
`exec zsh -c` to evaluate new tools, it uses `eval "$(mise activate bash)"` and
`eval "$(/opt/homebrew/bin/brew shellenv)"` directly in the active Bash session.
It only commits to `exec zsh -l` at the very end (Phase 5). This avoids
unpredictable subshell loops and keeps the bootstrap idempotent.
