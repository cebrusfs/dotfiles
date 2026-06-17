function fish_title
    # Keep terminal titles close to the zsh title hook while Starship owns prompt rendering.
    set -l command $argv[1]
    if test -z "$command"
        set command (status current-command)
    end
    if test "$command" = fish
        set command shell
    end

    printf '%s: %s' (prompt_hostname) (string sub -l 20 -- "$command")
end
