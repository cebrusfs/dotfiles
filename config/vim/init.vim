" vim: ts=4 sts=4 sw=4 et

if has('nvim') && filereadable(expand('~/.config/nvim/init.lua'))
    execute 'luafile' fnameescape(expand('~/.config/nvim/init.lua'))
else
    runtime vimrc
endif
