# Shell Migration Research

Research date: 2026-06-22

Temporary note: this document is a working research note for the zsh to fish
migration. Delete it after the related TODO in `README.md` is completed or no
longer relevant.

## Zsh to Fish

Status: fish is ready for a manual pilot, but not ready to become the default
login shell yet. `config/fish` starts cleanly under fish 4.7.1 in smoke tests,
and repo-managed fish artifacts are linked into `~/.config/fish` without
tracking fish runtime state.

Current repo state:
- `config/fish/` contains a migrated fish config, prompt, and function wrappers.
- `install-conf/dotbot.conf.yaml` links `config.fish`, `functions/`, `conf.d/`,
  and `completions/` individually so `~/.config/fish/fish_variables` stays local
  and untracked.
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
| `config/zsh/p10k.zsh` prompt left side | `functions/fish_prompt.fish`, `functions/__fish_dotfiles_jj_prompt.fish` | Ported: time, context, directory, jj, git fallback, status, command duration, prompt char. |
| P10k async jj worker | `__fish_dotfiles_jj_prompt` | Behavior is ported; fish pilot uses synchronous `jj --ignore-working-copy`. Revisit only if prompt latency is measurable. |
| P10k right prompt environment segments | none | Intentionally omitted for pilot; most are opportunistic P10k-specific indicators and not required for shell behavior parity. |
| Prezto terminal auto-title | `functions/fish_title.fish` | Ported for normal terminal titles; tmux title behavior remains managed by `config/tmux/tmux.conf`. |
| zsh completion user filters / ignored `**` | none | Not ported. Fish has different completion semantics and no stable equivalent was needed for the pilot. |

Benefits:
- Fish includes autosuggestions, syntax highlighting, and useful completions by
  default, reducing Prezto and plugin surface area.
- Interactive shell configuration is simpler and more explicit than zsh module
  setup.
- Fish integrates cleanly with `mise`, `fzf`, `jj` completion, and Ghostty shell
  integration.

Tradeoffs and risks:
- Fish is not POSIX shell. Many shell snippets using `export FOO=bar`,
  `[[ ... ]]`, arrays, process substitution, or bash/zsh function syntax must be
  translated before use.
- Powerlevel10k and Prezto configuration do not carry over directly.
- Fish universal-variable state such as `fish_variables` is runtime state and
  should not be tracked in this repo.
- Any shell-specific logic in zsh needs explicit parity checks before `chsh`.

Recommendation:
- Use fish manually for a trial period before changing the login shell.
- Treat zsh as the fallback until real interactive use verifies `mise`, editor,
  pager, completion, remote SSH, and tmux attach/reconnect workflows.

Verification command:

```sh
fish -n config/fish/config.fish config/fish/functions/*.fish
```

TODO:
- [ ] Add fish to the managed package set if the pilot continues.
- [x] Add dotbot links for repo-managed fish artifacts while keeping
  `fish_variables` local.
- [x] Port the zsh `SSH_AUTH_SOCK` refresh hook to fish for tmux reconnects.
- [ ] Add a fish syntax check to repo check tasks if a shared check runner is
  added.
- [ ] Run an interactive fish pilot covering `mise doctor`, `nvim`, `delta`,
  `fd` / `fzf`, `jj` completion, the `ssh` wrapper, and tmux attach/reconnect.
- [ ] Only after the pilot, decide whether to update install Phase 5 and run
  `chsh -s` for fish.

References:
- <https://fishshell.com/docs/current/>
- <https://fishshell.com/docs/current/fish_for_bash_users.html>
- <https://fishshell.com/docs/current/cmds/fish_add_path.html>
- <https://formulae.brew.sh/formula/fish>
