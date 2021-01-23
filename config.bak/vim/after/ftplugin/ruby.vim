" Colorcolumn
setlocal colorcolumn=80

setlocal tabstop=2
setlocal shiftwidth=2
setlocal softtabstop=2

" Syntastic
let g:syntastic_ruby_checkers=['rubocop', 'mri']

" Execute
nmap <buffer> <Leader>p     :w<CR>
                            \:!ruby %<CR>
