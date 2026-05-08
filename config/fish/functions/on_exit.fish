function on_exit --on-process-exit %self
    # Replicates Zsh's zlogout logic.
    # Only print "Bye!" if the shell is interactive.
    if status is-interactive
        echo -e "\nBye!" >&2
    end
end
