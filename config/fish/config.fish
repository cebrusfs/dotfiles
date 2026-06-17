# =============================================================================
# Fish Configuration (Migrated from Zsh)
# =============================================================================

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------

# OSX
# tar: Do NOT pack UI configuration file (e.g. .DS_Store)
set -gx COPYFILE_DISABLE true
# Homebrew: cask: Change default app install directory
set -gx HOMEBREW_CASK_OPTS "--appdir=~/Applications"

# GPG
set -gx GPG_TTY (tty)

# Browser
if test -z "$BROWSER"; and string match -q "darwin*" "$OSTYPE"
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
# Paths (using fish_add_path for idempotent prepending/appending)
# -----------------------------------------------------------------------------

fish_add_path -g $HOME/bin # Customized binary/script managed by git
fish_add_path -g $HOME/.local/bin # Python: uv path
for python_bin in $HOME/Library/Python/*/bin
    fish_add_path -g $python_bin
end
fish_add_path -g $HOME/.codeium/windsurf/bin # Windsurf
fish_add_path -g /opt/homebrew/bin /opt/homebrew/sbin # Default homebrew for Apple Silicon
fish_add_path -g /Library/TeX/texbin # Mactex
fish_add_path -g /usr/texbin # Linux latex

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

    # Enable vi key bindings
    fish_vi_key_bindings

    # Print a random adage on login
    if type -q fortune
        fortune -s >&2
        echo >&2
    end

    # Environment Variables
    if type -q nvim
        set -gx EDITOR nvim
    else if type -q vim
        set -gx EDITOR vim
    end
    set -gx VISUAL "$EDITOR"

    # PAGER
    if type -q delta
        set -gx PAGER delta
    else
        set -gx PAGER less
    end

    # FZF & fd
    if type -q fd
        set -gx FZF_DEFAULT_COMMAND "fd --type file"
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    else if type -q fdfind
        set -gx FZF_DEFAULT_COMMAND "fdfind --type file"
        set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
        alias fd fdfind
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
    end

    # Tmux alias wrapper
    if type -q tmx2
        alias tmux tmx2
    end

    # macOS RDP fix
    alias fixrdp 'sudo launchctl unload -w /System/Library/LaunchDaemons/com.apple.screensharing.plist && sudo launchctl load -w /System/Library/LaunchDaemons/com.apple.screensharing.plist'

    # Third-party initializations
    if type -q fzf
        fzf --fish | source 2>/dev/null
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

# -----------------------------------------------------------------------------
# Machine-local / Private Settings
# -----------------------------------------------------------------------------
# Source private settings if they exist (ignored by Git).
for local_config in config.local.fish config.corp.fish
    set -l local_path (dirname (status filename))/$local_config
    if test -f $local_path
        source $local_path
    end
end
