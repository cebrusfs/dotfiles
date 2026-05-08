function ssh
    # Get the target host from the first argument to use as the window name.
    set -l window_name $argv[1]

    # If there are no arguments or the first argument is an option (starts with '-'),
    # fallback to "ssh" as the window name.
    if test (count $argv) -ne 1; or string match -q "-*" "$window_name"
        set window_name ssh
    end

    # If running inside tmux, rename the current tmux window to the target host.
    if set -q TMUX
        tmux rename-window -t$TMUX_PANE "$window_name"
    end

    set -l err_count 0
    # Auto-reconnect loop
    while true
        # Record the start time to determine if the connection failed immediately or lasted a while.
        set -l start_time (date +%s)

        # Execute the actual system ssh command, bypassing this function wrapper.
        command ssh $argv
        set -l return_code $status

        # Exit the loop if the exit code is not 255.
        # SSH returns 255 when an error occurs (like network disconnection).
        # Normal exits (e.g., typing 'exit' on the remote host) return 0 or the last command's status.
        if test $return_code -ne 255
            break
        end

        # Calculate how long the session lasted.
        set -l end_time (date +%s)
        set -l time_diff (math "$end_time - $start_time")

        # If the session disconnected in less than 10 seconds, increment the error counter.
        # This prevents an infinite fast-retry loop if the host is completely unreachable.
        if test $time_diff -lt 10
            set err_count (math "$err_count + 1")
        else
            # Reset the counter if the connection was stable for more than 10 seconds.
            set err_count 0
        end

        # Give up after 10 consecutive fast failures.
        if test $err_count -gt 10
            break
        end

        # Print a retry message and wait 1 second before attempting to reconnect.
        echo -e "\r\e[1;33m[Disconnected. Retry ssh at "(date '+%F %T')"..]\e[0m"
        sleep 1
    end

    # Reset the tmux window name to automatic mode after the SSH session ends.
    if set -q TMUX
        tmux set-window-option -t$TMUX_PANE automatic-rename
    end

    # Return the exit status of the SSH command.
    return $return_code
end
