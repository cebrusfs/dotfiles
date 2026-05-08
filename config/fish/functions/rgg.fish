function rgg
    # Wrapper for ripgrep (rg) to search for files matching a specific pattern.
    # It disables path coloring and restricts the search to files matching the glob pattern 
    # provided as the first argument ($argv[1]), searching anywhere within the filename.
    rg --colors=path:none --files -g "*$argv[1]*"
end
