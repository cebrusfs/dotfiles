# Shell Migration Research

Research date: 2026-06-22

Temporary note: this document is a working research note for the zsh to fish
migration. Delete it after the related TODO in `README.md` is completed or no
longer relevant.

## Zsh to Fish

Status: fish is ready for a pilot, but not ready to become the default login
shell yet. `config/fish` starts cleanly under fish 4.7.1 in smoke tests, but the
install path and a few zsh parity items are still missing.

Current repo state:
- `config/fish/` contains a migrated fish config, prompt, and function wrappers.
- `install-conf/dotbot.conf.yaml` still links zsh files and does not link
  `~/.config/fish`.
- `config/zsh/zshrc` still has behavior not fully ported to fish, especially the
  tmux-aware `SSH_AUTH_SOCK` refresh hook used after reconnecting to tmux.

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
- Treat zsh as the fallback until tmux, SSH agent refresh, `mise`, editor, pager,
  completion, and remote workflows are verified.

TODO:
- [ ] Add fish to the managed package set if the pilot continues.
- [ ] Add a dotbot link for `~/.config/fish` after deciding the config should be
  installed by default.
- [ ] Port the zsh `SSH_AUTH_SOCK` refresh hook to fish for tmux reconnects.
- [ ] Add a fish syntax check to the repo check tasks.
- [ ] Run an interactive fish pilot covering `mise doctor`, `nvim`, `delta`,
  `fd` / `fzf`, `jj` completion, the `ssh` wrapper, and tmux attach/reconnect.
- [ ] Only after the pilot, decide whether to update install Phase 5 and run
  `chsh -s` for fish.

References:
- <https://fishshell.com/docs/current/>
- <https://fishshell.com/docs/current/fish_for_bash_users.html>
- <https://fishshell.com/docs/current/cmds/fish_add_path.html>
- <https://formulae.brew.sh/formula/fish>
