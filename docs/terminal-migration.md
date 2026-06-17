# Terminal Migration Research

Research date: 2026-06-22

Temporary note: this document is a working research note for the iTerm2 to
Ghostty migration. Delete it after the related TODO in `README.md` is completed
or no longer relevant.

## iTerm2 to Ghostty

Status: do not replace iTerm2 yet for workflows that depend on tmux control
mode. Ghostty is reasonable to pilot for normal terminal usage and plain tmux,
but it is not currently a drop-in replacement for iTerm2's `tmux -CC`
integration.

Current repo dependencies:
- `config/ssh/config` uses `RemoteCommand tmux -CC new -A -s tmux-main` for
  selected remote hosts.
- `config/tmux/tmux.conf` contains iTerm2 / `tmux -CC` title and rename
  workarounds.
- `homebrew/Brewfile.min` installs iTerm2; Ghostty is not part of the managed
  install set yet.

Benefits:
- Native, GPU-accelerated terminal with a simpler config model than iTerm2's
  plist.
- Good fit for local shells and ordinary tmux sessions.
- Supports shell integration for zsh and fish.

Tradeoffs and risks:
- iTerm2's control mode maps tmux windows and panes into native terminal UI.
  Ghostty does not yet provide equivalent `tmux -CC` behavior; plain tmux works
  but stays inside the terminal grid.
- Existing SSH profiles that force `tmux -CC` should keep using iTerm2 until the
  Ghostty control-mode gap is closed and re-tested.
- Remote hosts may need Ghostty terminfo installed or a conservative `TERM`
  fallback before using Ghostty over SSH.

Recommendation:
- Keep iTerm2 as the default for remote `tmux -CC` sessions.
- Pilot Ghostty only for local shells and plain tmux.
- If Ghostty becomes the primary terminal before control mode is fixed, split SSH
  profiles so iTerm2 hosts keep `tmux -CC` and Ghostty hosts run plain
  `tmux new -A -s tmux-main`.

TODO:
- [ ] Add Ghostty to a Brewfile only after a local pilot.
- [ ] Add `config/ghostty/config` and a dotbot link if Ghostty is adopted.
- [ ] Split SSH profiles or tags for iTerm2 control mode vs Ghostty plain tmux.
- [ ] Re-test the upstream Ghostty tmux control-mode issue before replacing
  iTerm2.
- [ ] Verify remote `TERM`, terminfo, OSC52 clipboard, and plain tmux behavior
  from Ghostty.

References:
- <https://iterm2.com/documentation-tmux-integration.html>
- <https://github.com/ghostty-org/ghostty/issues/1935>
- <https://github.com/ghostty-org/ghostty/discussions/12038>
- <https://ghostty.org/docs/help/terminfo>
- <https://ghostty.org/docs/features/shell-integration>
