" vim: ts=4 sts=4 sw=4 et

scriptencoding utf-8

" General {
    set nocompatible

    set history=1000
    set autoread

    set directory^=~/.vimfiles/swap,$TMPDIR
    set undodir^=~/.vimfiles/undo,$TMPDIR
    set undofile

    set clipboard^=unnamed,unnamedplus

    set fileencoding=utf-8
    set fileencodings=ucs-bom,utf-8,big5,cp936,gb18030,default,latin1

    set mouse=a

" }

" User Interface {
    set number
    set virtualedit=onemore

    set foldmethod=marker
    set foldlevel=1

    set copyindent
    set smarttab
    set expandtab

    set tabstop=4
    set shiftwidth=4
    set softtabstop=4

    if has('termguicolors')
        set termguicolors
    endif

    set colorcolumn=+1
    highlight ColorColumn guibg=firebrick4 ctermbg=52

    syntax enable
    filetype plugin indent on
" }

" General Key mapping {
    let mapleader="\<Space>"
    let maplocalleader="\<Space>"

    nnoremap <Leader>w :w<CR>
    nnoremap <Leader>e :e<CR>

    nnoremap <silent> <Down> g<Down>
    nnoremap <silent> <Up> g<Up>

    nmap <C-t>n :tabnew<CR>
    nmap <C-t><Left> :tabprevious<CR>
    nmap <C-t><Right> :tabnext<CR>
" }

" Programming env {
autocmd Filetype c,cpp setlocal textwidth=80
autocmd Filetype c
            \ nnoremap <buffer> <Leader>c
            \ :w<CR>
            \ :make %< CC=gcc CFLAGS="-std=c2x -O2 -Wall -Wextra -Wshadow"<CR>
            \ :cl<CR>
autocmd Filetype cpp
            \ nnoremap <buffer> <Leader>c
            \ :w<CR>
            \ :make %<
                \ CXX="`bash -c '(which g++-11) \\|\\| (which g++)'`"
                \ CXXFLAGS="-std=gnu++20 -O2 -Wall -Wextra -Wshadow -Wno-deprecated -DFISH"<CR>
            \:cl<CR>
autocmd Filetype c,cpp
            \ nnoremap <buffer> <Leader>p
            \ :!./%<<CR>

autocmd FileType gitcommit setlocal textwidth=72

autocmd FileType go
            \ setlocal textwidth=0 tabstop=2 shiftwidth=2 softtabstop=2 noexpandtab
autocmd Filetype go
            \ nnoremap <buffer> <Leader>p
            \ :w<CR>
            \ :!go run %<CR>

autocmd Filetype javascript
            \ nnoremap <buffer> <Leader>p
            \ :w<CR>
            \ :!node %<CR>

autocmd Filetype makefile setlocal noexpandtab

autocmd Filetype python
            \ nnoremap <buffer> <Leader>p
            \ :w<CR>
            \ :!python3 -W always -tt %<CR>

autocmd Filetype ruby
            \ nnoremap <buffer> <Leader>p
            \ :w<CR>
            \ :!ruby %<CR>

autocmd Filetype sh
            \ nnoremap <buffer> <Leader>p
            \ :w<CR>
            \ :!sh %<CR>

autocmd Filetype rust
            \ nnoremap <buffer> <Leader>c
            \ :w<CR>
            \ :!cargo check<CR>
autocmd Filetype rust
            \ nnoremap <buffer> <Leader>p
            \ :w<CR>
            \ :!RUST_BACKTRACE=1 cargo run<CR>
" }
