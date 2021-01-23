" TODO: use function to handle compile/default code/execution

" Colorcolumn
setlocal colorcolumn=80
setlocal wrap

" Default Code
nmap <buffer> <Leader>R  :0r ~/.vim/default_code/default.cpp<CR>
                         \:set fdm=marker<CR>
                         \/int main<CR>
                         \:noh<CR>

" Default Code - Google Code Jam
nmap <buffer> <Leader>Rg :0r ~/.vim/default_code/GoogleCodeJam.cpp<CR>
                \:set fdm=marker<CR>
                \/int main<CR>
                \:noh<CR>

" Compile
nmap <buffer> <Leader>c   :w<CR>
                \:make %<
                \ CXX="`(which g++-8 >/dev/null && which g++-8) \\|\\| (which g++-7 >/dev/null && which g++-7) \\|\\| (which g++ >/dev/null && which g++)`"
                \ CXXFLAGS="-std=gnu++1z -O2 -Wall -Wextra -Wshadow -Wno-deprecated -DFISH"<CR>
                \:cl<CR>

" Execute
nmap <buffer> <Leader>p   :!./%<<CR>
