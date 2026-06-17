function rgg
    # Search tracked path names by glob fragment without ripgrep path coloring.
    rg --colors=path:none --files -g "*$argv[1]*"
end
