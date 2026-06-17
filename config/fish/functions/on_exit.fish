function on_exit --on-process-exit %self
    # Mirror zlogout's interactive farewell without polluting non-TTY shells.
    status is-interactive; or return
    isatty stderr; or return

    printf '\nBye!\n' >&2
end
