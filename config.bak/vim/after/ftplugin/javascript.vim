" Colorcolumn
setlocal colorcolumn=80

" Execute
nmap <buffer> <Leader>p   :w<CR>
                \:!node %<CR>
