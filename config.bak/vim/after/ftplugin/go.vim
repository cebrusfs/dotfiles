" Colorcolumn
setlocal colorcolumn=80

setlocal noexpandtab
setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2
setlocal textwidth=80

" Execute
nmap <buffer> <Leader>p :w<CR>
                        \:!go run %<CR>
