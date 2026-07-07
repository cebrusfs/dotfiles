function rgg --wraps fd
    # Legacy alias migrated to use fd
    set_color yellow
    echo "Warning: 'rgg' is deprecated, please use 'fd' directly." >&2
    set_color normal
    fd $argv
end
