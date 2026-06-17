function ssh
    # Use the destination as a tmux window hint for single-host ssh sessions.
    set -l window_name $argv[1]

    if test (count $argv) -ne 1; or string match -q "-*" "$window_name"
        set window_name ssh
    end

    if set -q TMUX; and type -q tmux
        tmux rename-window -t$TMUX_PANE "$window_name"
    end

    set -l err_count 0
    while true
        # Reconnect only on SSH transport failures; fast repeated failures stop the loop.
        set -l start_time (date +%s)

        command ssh $argv
        set -l return_code $status

        if test $return_code -ne 255
            break
        end

        set -l end_time (date +%s)
        set -l time_diff (math "$end_time - $start_time")

        # A session that lived long enough resets the fast-failure counter.
        if test $time_diff -lt 10
            set err_count (math "$err_count + 1")
        else
            set err_count 0
        end

        if test $err_count -gt 10
            break
        end

        echo -e "\r\e[1;33m[Disconnected. Retry ssh at "(date '+%F %T')"...]\e[0m"
        sleep 1
    end

    # Hand tmux window naming back after the SSH session finishes.
    if set -q TMUX; and type -q tmux
        tmux set-window-option -t$TMUX_PANE automatic-rename
    end

    return $return_code
end
