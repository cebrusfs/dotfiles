" vim: ts=4 ts=4 sts=4
" vim: foldmarker={,} foldlevel=0 foldmethod=marker:

scriptencoding utf-8

" General {
    set nocompatible

    " Store a ton of history (default is 20)
    set history=1000

    " Auto read when file is changed from outside
    set autoread

    " Directory of swap files
    set directory^=~/.vimfiles/swap,/tmp

    " Directory of undo files
    set undodir^=~/.vimfiles/undo,/tmp
    set undofile

    " Clipboard: Use both * and + registers clipboard buffer (OSX, Windows, Linux)
    "
    " clipboard^=unnamed,unnamedplus means:
    "   unnamed  = Link unnamed register to * (primary selection)
    "   unnamedplus = Link unnamed register to + (system clipboard)
    "   ^= operator = Prepend to the list (higher priority than existing values)
    "
    " This ensures both clipboard selections sync with Vim on X11/Linux.
    " On macOS, * and + point to the same clipboard, so both have same effect.
    "
    " Known issue (Neovim over SSH/tmux): https://github.com/neovim/neovim/issues/1822
    set clipboard^=unnamed,unnamedplus

    " Encoding
    set fileencoding=utf-8
    " default "ucs-bom,utf-8,default,latin1"
    set fileencodings=ucs-bom,utf-8,big5,cp936,gb18030,default,latin1

    " Enable mouse support (Don't use Cmd+C to copy in OSX)
    set mouse=a

    " Disable provider of nvim
    let g:loaded_perl_provider = 0
    let g:loaded_ruby_provider = 0
    let g:loaded_node_provider = 0
" }

" User Interface {
    set number              " line number

    set virtualedit=onemore " Allow for cursor beyond last character

    set foldmethod=marker   " fold
    set foldlevel=1

    set copyindent          " copy the previous indentation on autoindenting
    set smarttab            " insert tabs on the start of a line according to context
    set expandtab           " use spaces instead of tabs

    " 1 tab == 4 spaces
    set tabstop=4
    set shiftwidth=4
    set softtabstop=4
" }

" General Key mapping {
    " Set <Space> as leader key
    let mapleader="\<Space>"
    let maplocalleader="\<Space>"

    " Quick load/save
    nnoremap <Leader>w :w<CR>
    nnoremap <Leader>e :e<CR>

    " Move between wrapped line
    nnoremap <silent> <Down> g<Down>
    nnoremap <silent> <Up> g<Up>

    " Move between tabs
    " Create a new tab
    nmap <C-t>n :tabnew<CR>
    " default: gT or ctrl-PageUp
    nmap <C-t><Left> :tabprevious<CR>
    " default: gt or ctrl-PageDown
    nmap <C-t><Right> :tabnext<CR>
" }


" Enable plugins {
call plug#begin()

" Color Scheme {
    Plug 'tomasiser/vim-code-dark'
    Plug 'Mofiqul/vscode.nvim' " Neovim only

    " Other theme, still trying
    " Plug 'loctvl842/monokai-pro.nvim'
    " Plug 'folke/tokyonight.nvim'
" }

" vim-airline: Powerful status bar {
    Plug 'vim-airline/vim-airline'

    " airline themes
    " Plug 'vim-airline/vim-airline-themes'
    Plug 'jacoborus/tender.vim'
    let g:airline_theme = 'tender'

    " Enable power line fonts
    let g:airline_powerline_fonts = 1


    " Note: airline integration with another vim plugins
    "   coc:        integration is default on. No more config is needed.
    "   git-branch: tpope/vim-fugitive
    "   git-status: coc-git
" }

" Indent: Show indent space and tab with colors {
    Plug 'nathanaelkane/vim-indent-guides'

    if !has('nvim')
        " Self-define color for layers
        let g:indent_guides_auto_colors=0
        autocmd VimEnter,Colorscheme * highlight IndentGuidesOdd  guibg=grey27   ctermbg=238
        autocmd VimEnter,Colorscheme * highlight IndentGuidesEven guibg=grey42   ctermbg=242

        " Width only 1
        let g:indent_guides_guide_size=1

        let g:indent_guides_enable_on_vim_startup=1
    endif

    Plug 'lukas-reineke/indent-blankline.nvim' " Neovim only
" }
" vim-ShowTrailingWhitespace: Show trailing whitespace {
    Plug 'inkarkat/vim-ingo-library' " Dependancy of ShowTrailingWhitespace
    Plug 'inkarkat/vim-ShowTrailingWhitespace'
" }
" rainbow: Colorized parantheses () <> {
    Plug 'luochen1990/rainbow'

    let g:rainbow_active = 1

    " 0: disable
    let g:rainbow_conf = {
        \   'separately': {
        \       'tex': {
        \           'parentheses': ['start=/(/ end=/)/', 'start=/\[/ end=/\]/'],
        \       },
        \       'html': {
        \           'parentheses': ['start=/\v\<((area|base|br|col|embed|hr|img|input|keygen|link|menuitem|meta|param|source|track|wbr)[ >])@!\z([-_:a-zA-Z0-9]+)(\s+[-_:a-zA-Z0-9]+(\=("[^"]*"|'."'".'[^'."'".']*'."'".'|[^ '."'".'"><=`]*))?)*\>/ end=#</\z1># fold'],
        \       },
        \       'css': 0,
        \       'c': 0,
        \       'cpp': 0,
        \       'python': 0
        \   }
        \}
" }

" Programming integration (Neovim only) {
if has('nvim')
    Plug 'neovim/nvim-lspconfig'            " LSP configuration

    " LSP/Formatter/Linter management via Mason
    Plug 'mason-org/mason-lspconfig.nvim'   " mason-lspconfig bridges mason.nvim with the lspconfig plugin
    Plug 'mason-org/mason.nvim'

    " Autocompletion engine: nvim-cmp
    Plug 'hrsh7th/cmp-nvim-lsp'             " Auto completing from LSP
    Plug 'hrsh7th/cmp-buffer'               " Word completing from current opened buffer
    Plug 'hrsh7th/cmp-path'                 " Path auto completing
    Plug 'hrsh7th/cmp-cmdline'              " Vim command line completing
    Plug 'hrsh7th/nvim-cmp'

    " Fuzzy Finding: fzf-lua
    Plug 'ibhagwan/fzf-lua', { 'branch': 'main' }  " fzf-lua: Lua binding for fzf

    " Git Integration
    Plug 'lewis6991/gitsigns.nvim'
endif
" }


" vim-fugitive: git integration {
    " TODO: compare neogit or lazygit?
    Plug 'tpope/vim-fugitive'

    nnoremap <silent> <Plug>(key-git)s      :<C-u>Git<CR>
    nnoremap <silent> <Plug>(key-git)d      :<C-u>Gdiff<CR>
    " nnoremap <silent> <Plug>(key-git)dp      :<C-u>diffput<CR>
    " nnoremap <silent> <Plug>(key-git)dg      :<C-u>diffget<CR>
    nnoremap <silent> <Plug>(key-git)b      :<C-u>Git blame<CR>
    nnoremap <silent> <Plug>(key-git)m      :<C-u>Git mergetool<CR>
" }

" vim-easy-align: align tool {
    Plug 'junegunn/vim-easy-align'

    " Start interactive EasyAlign in visual mode (e.g. vipga)
    xmap <Leader>- <Plug>(EasyAlign)
    " Start interactive EasyAlign for a motion/text object (e.g. gaip)
    nmap <Leader>- <Plug>(EasyAlign)
" }
" vim-pasta: Auto align when pasting code {
    Plug 'sickill/vim-pasta'

    " example of disable list
    "let g:pasta_disabled_filetypes = ['python', 'coffee', 'yaml']
" }

" nerdtree: {
    Plug 'preservim/nerdtree'
    let g:NERDTreeIgnore=['\~$', '\.o$', '\.pyc$']
    " NERDTree: Shift + Tab
    nnoremap <S-Tab> :NERDTreeToggle<CR>
" }

" nerdcommenter {
    Plug 'preservim/nerdcommenter'

    " Disable all default mappings
    let g:NERDCreateDefaultMappings = 0
    " Add spaces after comment delimiters by default
    let g:NERDSpaceDelims = 1
    " Use compact syntax for prettified multi-line comments
    let g:NERDCompactSexyComs = 1
    " Allow commenting and inverting empty lines (useful when commenting a region)
    let g:NERDCommentEmptyLines = 1
    " Enable NERDCommenterToggle to check all selected lines is commented or not
    let g:NERDToggleCheckAllLines = 1

    let g:NERDCustomDelimiters = {
        \'armasm': {'left': '@'},
    \}

    " \: backslash to comment
    nmap <Bslash> <Plug>NERDCommenterToggle
    xmap <Bslash> <Plug>NERDCommenterToggle
" }

" vim-endwise: Ruby: auto add 'end' for loop/functions {
    Plug 'tpope/vim-endwise'

    " Ref: https://github.com/tpope/vim-endwise/issues/109#issuecomment-538833949
    " let g:endwise_no_mappings = 1
    " imap <expr> <CR> (pumvisible() ? "\<C-e>\<CR>\<Plug>DiscretionaryEnd" : "\<CR>\<Plug>DiscretionaryEnd")
" }


" vim-polyglot: All language syntax highlight {
    Plug 'sheerun/vim-polyglot'

    " Use vim-pandoc instead
    let g:polyglot_disabled = ['markdown']
" }
" vim-pandoc: Syntax highlight for markdown {
    Plug 'vim-pandoc/vim-pandoc'
    Plug 'vim-pandoc/vim-pandoc-syntax'

    " Conceal the links
    let g:pandoc#syntax#conceal#urls = 1
" }
" Mojom syntax highlight {
    Plug 'ShikChen/mojom.vim'
" }
" BUILD.gn syntax highlight {
    Plug 'https://gn.googlesource.com/gn', { 'rtp': 'misc/vim' }
" }

" local-vimrc 'lvimrc': {
    Plug 'coquelicot/local-vimrc'
" }


" AI integration {
    " Online AI coding completion, faster than copilot
    " Plug 'supermaven-inc/supermaven-nvim'

    " Microsoft copilot
    " Plug 'github/copilot.vim'
" }

" vim-easymotion: Fast jump {
    Plug 'easymotion/vim-easymotion'
" }

" Grammar checker: {
    Plug 'rhysd/vim-grammarous'

    " Check comments only in source code by default
    let g:grammarous#default_comments_only_filetypes = {
        \ '*' : 1,
        \ 'help' : 0,
        \ 'markdown' : 0,
        \ }
" }

" Clipboard: {
    " Currently Vim could access clipboard on remote over tmux.
    " We fetch the clipboard via tmux integration. Alought it is not actively
    " used, this is still useful if we directly connect over SSH.
    Plug 'ShikChen/osc52.vim'
    vnoremap Y y:call SendViaOSC52(getreg('"'))<CR>
" }

call plug#end()
" }


" Colorscheme settings {
    " True-color support
    if has("termguicolors")
        set termguicolors
    endif


    " Load lua to setup the colorscheme on neovim
    if has("nvim")
        lua require('config')
    else
        " Fallback for vim
        colorscheme codedark
    endif
" }

" Wrap the long lines and highlight wrap limit {
    set colorcolumn=+1
    " FIXME: color
    highlight ColorColumn guibg=firebrick4 ctermbg=52
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

" -tt inconsistent tab usage (-tt: issue errors)
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
