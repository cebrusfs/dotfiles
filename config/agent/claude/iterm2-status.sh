#!/usr/bin/env bash

# iTerm2 owns cc-status; installations without it need no status integration.
iterm_status_command="$HOME/.config/iterm2/cc-status"
[[ -x "$iterm_status_command" ]] || exit 0
exec "$iterm_status_command"
