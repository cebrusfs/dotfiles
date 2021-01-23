" Colorcolumn
setlocal colorcolumn=80
setlocal wrap

" Compile
nmap <buffer> <Leader>c   :w<CR>
                \:make %< CC=gcc CFLAGS="-std=c11 -O2 -Wall -Wextra -Wshadow"<CR>
                \:cl<CR>

" Execute
nmap <buffer> <Leader>p   :!./%<<CR>
