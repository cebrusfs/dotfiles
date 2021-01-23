" Colorcolumn
setlocal colorcolumn=80

" Syntastic
let g:syntastic_python_checkers=['pylint']

" C0103, naming convention
" C0111, missdocsting
" C0301, line too long
" C0325, Unnecessary parens after 'print' keyword (superfluous-parens) (python3)
" W0141, Used builtin function 'map', 'filter', 'reduce'
" W0142, Used * or ** magic
let g:syntastic_python_pylint_post_args='-d C0111,C0103,C0301,C0325,W0141,W0142'

" Execute
nmap <buffer> <Leader>p     :w<CR>
                            \:!python -W always -t %<CR>
