function fish_prompt
    # Store the exit status of the last executed command.
    # This must be done immediately, otherwise the status will be overwritten by subsequent commands.
    set -l last_status $status

    # Error code indicator:
    # If the last command failed (non-zero exit status), display the code in red.
    if test $last_status -ne 0
        set_color red
        printf '[%s] ' $last_status
    end

    # PWD indicator:
    # Display the current working directory in cyan. 
    # 'prompt_pwd' automatically abbreviates long paths (e.g., replaces $HOME with ~).
    set_color cyan
    printf '%s' (prompt_pwd)

    # VCS (Version Control System) indicator:
    # Uses Fish's native `fish_vcs_prompt` to display Git, Mercurial, Subversion, and Jujutsu (jj) status.
    # Note: Native Jujutsu support requires fish >= 3.7.0.
    set_color normal
    printf '%s' (fish_vcs_prompt)

    # Prompt symbol:
    # Print the final character of the prompt in green.
    set_color green
    printf ' ❯ '

    # Reset color to normal before user input.
    set_color normal
end
