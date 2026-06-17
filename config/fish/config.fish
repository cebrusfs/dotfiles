# =============================================================================
# Fish Configuration (Zsh parity pilot)
# =============================================================================

function __fish_dotfiles_warn
    set_color red >&2
    printf '[WARN] %s\n' "$argv[1]" >&2
    set_color normal >&2
end

function __fish_dotfiles_add_path_if_dir
    set -l paths
    for path in $argv
        if test -d "$path"
            set -a paths "$path"
        end
    end

    if test (count $paths) -gt 0
        fish_add_path --path --move $paths
    end
end

# Fish already provides the Prezto pieces used by zsh for autosuggestions,
# syntax highlighting, completion, history search, and basic prompt plumbing.
# After the fish migration is final, the zsh-only Prezto/P10k/async files are
# candidates to delete; keep them while zsh remains the fallback shell.

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------

# OSX
# tar: Do NOT pack UI configuration file (e.g. .DS_Store)
set -gx COPYFILE_DISABLE true
# Homebrew: cask: Change default app install directory
set -gx HOMEBREW_CASK_OPTS "--appdir=~/Applications"

# GPG
set -l __fish_dotfiles_gpg_tty (tty 2>/dev/null)
if test $status -eq 0
    set -gx GPG_TTY $__fish_dotfiles_gpg_tty
end
set -e __fish_dotfiles_gpg_tty

# Browser
if test -z "$BROWSER"; and test (uname -s 2>/dev/null) = Darwin
    set -gx BROWSER open
end

# Language
if test -z "$LANG"
    set -gx LANG "en_US.UTF-8"
end

# Less
if test -z "$LESS"
    set -gx LESS "-g -i -M -R -S -w -z-4"
end
set -gx LESSCHARSET UTF-8

# Set the Less input preprocessor
if test -z "$LESSOPEN"
    if type -q lesspipe.sh
        set -gx LESSOPEN "| /usr/bin/env lesspipe.sh %s 2>&-"
    else if type -q lesspipe
        set -gx LESSOPEN "| /usr/bin/env lesspipe %s 2>&-"
    end
end

# ls colors
# BSD (mac)
set -gx LSCOLORS Gxfxcxdxbxegedabagacad
# Linux
set -gx LS_COLORS "di=1;36:ln=35:so=32:pi=33:ex=31:bd=34;46:cd=34;43:su=30;41:sg=30;46:tw=30;42:ow=30;43"

# -----------------------------------------------------------------------------
# Paths
# -----------------------------------------------------------------------------

# User-managed scripts and per-user tool shims.
set -l __fish_dotfiles_paths \
    $HOME/bin \
    $HOME/.local/bin

# Python --user installs put console scripts under versioned framework dirs.
for python_bin in $HOME/Library/Python/*/bin
    set -a __fish_dotfiles_paths $python_bin
end

# GUI/editor shims, platform package managers, TeX, and ChromiumOS tooling.
set -a __fish_dotfiles_paths \
    $HOME/.codeium/windsurf/bin \
    /opt/homebrew/bin \
    /opt/homebrew/sbin \
    /Library/TeX/texbin \
    /usr/texbin \
    $HOME/working/cros_script/bin \
    $HOME/depot_tools \
    $HOME/crosfleet

__fish_dotfiles_add_path_if_dir $__fish_dotfiles_paths
set -e __fish_dotfiles_paths

# Source machine-local/private settings if they exist. This mirrors
# `config.local.zsh`; keep corp-specific shell logic out of tracked files.
set -l __fish_dotfiles_local_path (dirname (status filename))/config.local.fish
if test -f $__fish_dotfiles_local_path
    source $__fish_dotfiles_local_path
end
set -e __fish_dotfiles_local_path

# Fish has no `noclobber` equivalent enabled by default, so zsh's explicit
# `setopt clobber` does not need a fish setting.

# Starship owns prompt rendering; fish still owns commandline suggestion and
# completion pager colors.
set -g fish_color_autosuggestion brblack
set -g fish_color_valid_path --underline
set -g fish_pager_color_completion --reset
set -g fish_pager_color_description yellow --italics
set -g fish_pager_color_prefix --bold --underline
set -g fish_pager_color_selected_background --background=238

# Prompt event hook, not prompt rendering; Starship's fish_prompt still triggers it.
function __fish_dotfiles_ssh_auth_sock_refresh --on-event fish_prompt
    set -q TMUX; or return
    type -q tmux; or return

    set -l line (tmux show-environment SSH_AUTH_SOCK 2>/dev/null)
    or return
    string match -q 'SSH_AUTH_SOCK=*' -- $line; or return

    set -l sock (string replace -r '^SSH_AUTH_SOCK=' '' -- $line)
    if string match -q '/*' -- $sock; and test -S "$sock"
        set -gx SSH_AUTH_SOCK "$sock"
    end
end

# -----------------------------------------------------------------------------
# Interactive Shell Configurations
# -----------------------------------------------------------------------------

# Only execute the following configurations in interactive shells.
if status is-interactive
    # Terminal settings
    # Disable flow control (Ctrl-S/Ctrl-Q) to allow Ctrl-S for other bindings.
    stty -ixon 2>/dev/null

    # Mise (Runtime Executor) — corp runs mise too (e.g. neovim), so do not gate on /usr/local/bin/mule
    if type -q mise
        mise activate fish | source
    end

    if type -q starship
        # Starship owns fish_prompt/fish_right_prompt. If it is unavailable,
        # fish falls back to its built-in prompt instead of a repo-maintained one.
        starship init fish | source
    end

    # zsh uses Prezto's emacs key bindings; fish's default key bindings match.
    fish_default_key_bindings

    # zlogin prints fortune only for interactive login shells.
    if status is-login; and isatty stderr; and type -q fortune
        fortune -s >&2
        echo >&2
    end

    # Environment Variables
    if test -z "$EDITOR"
        if type -q nvim
            set -gx EDITOR nvim
        else if type -q vim
            set -gx EDITOR vim
            __fish_dotfiles_warn "'nvim' is not installed"
        end
    end

    if test -z "$VISUAL"; and test -n "$EDITOR"
        set -gx VISUAL "$EDITOR"
    end

    # PAGER
    if type -q delta
        set -gx PAGER delta
    else
        set -gx PAGER less
        __fish_dotfiles_warn "'delta' is not installed"
    end

    # FZF & fd
    if type -q fd
        set -gx FZF_DEFAULT_COMMAND "fd --type file"
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    else if type -q fdfind
        set -gx FZF_DEFAULT_COMMAND "fdfind --type file"
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        alias fd fdfind
    else
        __fish_dotfiles_warn "'fd' is not installed"
    end

    # Aliases
    alias rm 'rm -r'
    alias cp 'cp -rv'
    alias objdump 'objdump -M intel'

    # Git alias wrapper
    alias gws gwS

    # Editor aliases
    if type -q nvim
        alias vim nvim
        alias vimdiff "nvim -d"
    else
        __fish_dotfiles_warn "'neovim' is not installed"
    end

    type -q rg; or __fish_dotfiles_warn "'rg' is not installed"
    type -q fzf; or __fish_dotfiles_warn "'fzf' is not installed"

    # Tmux alias wrapper
    if type -q tmx2
        alias tmux tmx2
    end

    # macOS RDP fix
    alias fixrdp 'sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist && sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist'

    # Third-party initializations
    if type -q fzf
        if fzf --fish >/dev/null 2>&1
            fzf --fish | source
        end
    end

    # OrbStack
    if test -f ~/.orbstack/shell/init.fish
        source ~/.orbstack/shell/init.fish 2>/dev/null
    end

    # Jujutsu (jj) Completion
    if type -q jj
        jj util completion fish | source
    end
end
