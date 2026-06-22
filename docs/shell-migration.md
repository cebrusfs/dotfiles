# Shell Migration Research

Research date: 2026-06-22

Decision record for the zsh to fish migration. Keep this note while fish and
jj prompt support remain relevant to future shell decisions.

## Zsh to Fish

Status: do not migrate the default login shell to fish. `config/fish` starts
cleanly under fish 4.7.1 in smoke tests, and repo-managed fish artifacts are
linked into `~/.config/fish` without tracking fish runtime state, but the daily
prompt path is worse than the current zsh setup for jj-heavy work.

Current repo state:
- `config/fish/` contains a migrated fish config, prompt, and function wrappers.
- `install-conf/dotbot.conf.yaml` links `config.fish`, `functions/`, `conf.d/`,
  and `completions/` individually so `~/.config/fish/fish_variables` stays local
  and untracked.
- `config/starship/starship.toml` is linked to `~/.config/starship.toml` for the
  fish Starship prompt experiment.
- No fish plugin manager is used. Fish built-ins cover autosuggestions, syntax
  highlighting, completion, and history search; `fzf --fish` and
  `jj util completion fish` are sourced dynamically from the installed binaries.

## Side-by-Side Parity

| Zsh source | Fish target | Status |
|---|---|---|
| `config/zsh/zshenv` env vars | `config/fish/config.fish` | Ported: `COPYFILE_DISABLE`, `HOMEBREW_CASK_OPTS`, `GPG_TTY`, and `config.local.fish`. |
| `config/zsh/zprofile` login env | `config/fish/config.fish` | Ported: `BROWSER`, `LANG`, `LESS`, `LESSCHARSET`, `LESSOPEN`, `LSCOLORS`, `LS_COLORS`, and PATH prefixes. |
| zsh `path=(... $path)` | `fish_add_path --path --move` | Ported with immediate PATH ordering and missing-directory filtering. |
| `config/zsh/zshrc` tool setup | `config/fish/config.fish` | Ported: `mise`, `EDITOR`, `VISUAL`, `PAGER`, `fd`/`fdfind`, `fzf`, `rg`, `nvim`, `tmx2`, `OrbStack`, and `jj` completion. |
| `config/zsh/zshrc` aliases/functions | `config/fish/config.fish`, `functions/` | Ported: `rm`, `cp`, `objdump`, `fixrdp`, `gws`, `rgg`, and `ssh`. |
| zsh tmux `SSH_AUTH_SOCK` refresh | `__fish_dotfiles_ssh_auth_sock_refresh` | Ported with a fish prompt event hook. |
| `config/zsh/zlogin` | `config/fish/config.fish` | Ported for `fortune` on interactive login shells. `zcompdump` compile is zsh-only. |
| `config/zsh/zlogout` | `functions/on_exit.fish` | Ported with interactive TTY guard. |
| `config/zsh/zpreztorc` editor mode | `fish_default_key_bindings` | Ported: zsh uses emacs key bindings, fish default matches. |
| `config/zsh/zpreztorc` modules | fish built-ins / dynamic binary completions | Intentionally omitted where fish already provides native behavior: autosuggestions, syntax highlighting, completion, history search. |
| `config/zsh/p10k.zsh` prompt | `config/starship/starship.toml` | Ported as the primary prompt: time, context, directory, jj-starship change/bookmark/status display, git fallback, status, command duration, jobs, selected environment modules, battery, and prompt char. |
| P10k async jj worker | Starship `custom.jj` | Not adopted for the default shell. Fish does not provide a P10k-style async prompt worker path here, and the synchronous Starship / `jj-starship` prompt path is too weak for jj-heavy daily use. |
| P10k right prompt environment segments | Starship modules | Partially ported for common runtime/cloud/battery signals. P10k-specific indicators remain out of scope while fish is inactive. |
| Prezto terminal auto-title | `functions/fish_title.fish` | Ported for normal terminal titles; tmux title behavior remains managed by `config/tmux/tmux.conf`. |
| zsh completion user filters / ignored `**` | none | Not ported. Fish has different completion semantics and no stable equivalent is needed while fish is inactive. |

Benefits:
- Fish includes autosuggestions, syntax highlighting, and useful completions by
  default, reducing Prezto and plugin surface area.
- Interactive shell configuration is simpler and more explicit than zsh module
  setup.
- Fish integrates cleanly with `mise`, `fzf`, and Ghostty shell integration.

Tradeoffs and risks:
- Fish is not POSIX shell. Many shell snippets using `export FOO=bar`,
  `[[ ... ]]`, arrays, process substitution, or bash/zsh function syntax must be
  translated before use.
- Powerlevel10k and Prezto configuration do not carry over directly.
- Fish lacks the async prompt worker model this setup relies on for responsive
  VCS prompt segments.
- jj support is the deciding blocker: prompt latency and feature parity through
  Starship / `jj-starship` are not good enough to replace the current zsh and
  Powerlevel10k path.
- Fish universal-variable state such as `fish_variables` is runtime state and
  should not be tracked in this repo.
- Any shell-specific logic in zsh needs explicit parity checks before `chsh`.

Recommendation:
- Keep zsh as the default login shell.
- Keep `config/fish` as a reference and manual experiment, not as the active
  migration target.
- Revisit only if the fish prompt stack gets a reliable async path and jj
  support improves enough for daily prompt use.

Verification command:

```sh
fish -n config/fish/config.fish config/fish/functions/*.fish
```

Outcome:
- Do not add fish to the managed package set for the migration.
- Do not update install Phase 5 or run `chsh -s` for fish.
- Do not add fish syntax checks to shared repo checks unless `config/fish`
  becomes active again.

References:
- <https://fishshell.com/docs/current/>
- <https://fishshell.com/docs/current/fish_for_bash_users.html>
- <https://fishshell.com/docs/current/cmds/fish_add_path.html>
- <https://formulae.brew.sh/formula/fish>
