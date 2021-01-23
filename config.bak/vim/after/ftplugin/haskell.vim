"Compiler

"Complete Engine
let g:haskellmode_completion_ghc = 0
setlocal omnifunc=necoghc#omnifunc

" Override foldmethod
setlocal foldmethod=marker

" Default Code
nmap <buffer> <Leader>R   :0r ~/.vim/default_code/default.hs<CR>
                \:set fdm=marker<CR>
                \/main<CR>
                \:noh<CR>

" Compile
nmap <buffer> <Leader>c   :w<CR>
                \:!ghc -O2 -Wall %<CR>

" Execute
nmap <buffer> <Leader>p   :!./%<<CR>
