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

    " clipboard: Use both * and + registers clipboard buffer. (OSX, Windows,
    " Linux)
    " Known issue: https://github.com/neovim/neovim/issues/1822
    set clipboard^=unnamed,unnamedplus

    " Encoding
    set fileencoding=utf-8
    " default "ucs-bom,utf-8,default,latin1"
    set fileencodings=ucs-bom,utf-8,big5,cp936,gb18030,default,latin1

    " Enable mouse support (Don't use Cmd+C to copy in OSX)
    set mouse=a
" }

" User Interface {
    set number              " line number

    set virtualedit=onemore " Allow for cursor beyond last character

    set foldmethod=marker   " fold
    set foldlevel=1

    "set autoindent         " auto indentation
    set copyindent          " copy the previous indentation on autoindenting
    set smarttab            " insert tabs on the start of a line according to context
    set expandtab           " use spaces instead of tabs

    " 1 tab == 4 spaces
    set tabstop=4
    set shiftwidth=4
    set softtabstop=4

    " Auto complete menu {
    " " disable preview window when completing (default: menu,preview)
    " set completeopt-=preview
    " set wildmenu            " use menu when completing
    " set wildchar=<TAB>        " start wild expansion in the command line using

    " set wildignore^=*.o,*.class,*.pyc " ignore these files while expanding wild chars
    " }

    " Linebreaking Settings {
    " }
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
    Plug 'lukas-reineke/indent-blankline.nvim' " Neovim only
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

    " Fuzzy Finding
    " Plug 'nvim-lua/plenary.nvim' " Common utilities, dependency for telescope
    " Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.x' }

    " Git Integration
    Plug 'lewis6991/gitsigns.nvim'
endif
" }

" coc: Intellisense engine for Vim8 & Neovim, full language server protocol support as VSCode {
" TODO: switch to nvim native lsp to reduce the depednancy? cons: lose lsp
" support on tranditional vim.
    " Plug 'neoclide/coc.nvim', {'branch': 'release'}

if 0
    " Programming language extensions
    let g:coc_global_extensions = [
        "\ C/C++/Objective-C
        \'coc-clangd',
        "\ Python3
        \'coc-pyright',
        "\ \'@yaegassy/coc-ruff',
        "\ Ruby
        \'coc-solargraph',
        "\ Golang
        \'coc-go',
        "\ Javascript/TypeScript
        \'coc-tsserver',
        "\ Rust
        \'coc-rust-analyzer',
        "\ sh
        \'coc-sh',
        "\ JSON
        \'coc-json',
        "\ YAML
        \'coc-yaml',
        "\ formater: 'prettier': JavaScript/TypeScript/Flow/JSX/JSON/CSS/SCSS/Less
        "\   HTML/Vue/Angular/GraphQL/Markdown/YAML
        \'coc-prettier',
    \]

    " User Interface extensions
    let g:coc_global_extensions += [
        "\ Fzf integration
        \'coc-fzf-preview',
        "\ Git integration
        \'coc-git',
        "\ Highlight API
        \'coc-highlight',
    \]

    let g:coc_filetype_map = {
        \'pandoc': 'markdown'
    \}
endif

    " ==============================================================
    " Offcial references settings of coc
    " https://github.com/neoclide/coc.nvim#example-vim-configuration
    " ==============================================================

    " May need for Vim (not Neovim) since coc.nvim calculates byte offset by count
    " utf-8 byte sequence
    set encoding=utf-8
    " Some servers have issues with backup files, see #649
    set nobackup
    set nowritebackup

    " Having longer updatetime (default is 4000 ms = 4s) leads to noticeable
    " delays and poor user experience
    set updatetime=300

    " Note: (cebrusfs) Disabled. Use 'auto' by default.
    " Always show the signcolumn, otherwise it would shift the text each time
    " diagnostics appear/become resolved
    " set signcolumn=yes

if 0
    " Use tab for trigger completion with characters ahead and navigate
    " NOTE: There's always complete item selected by default, you may want to enable
    " no select by `"suggest.noselect": true` in your configuration file
    " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
    " other plugin before putting this into your config
    inoremap <silent><expr> <TAB>
          \ coc#pum#visible() ? coc#pum#next(1) :
          \ CheckBackspace() ? "\<Tab>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

    " Make <CR> to accept selected completion item or notify coc.nvim to format
    " <C-g>u breaks current undo, please make your own choice
    inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                                  \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    function! CheckBackspace() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " Note: (cebrusfs) manually trigger completion is not useful, disabled.
    " Use <c-leader> to trigger completion
    " if has('nvim')
      " inoremap <silent><expr> <c-leader> coc#refresh()
    " else
      " inoremap <silent><expr> <c-@> coc#refresh()
    " endif

    " Note: (cebrusfs) define my keymapping. {
        nmap <Leader>j <Plug>(key-goto)
        nmap <Leader>l <Plug>(key-list)
        nmap <Leader>g <Plug>(key-git)

        nmap <Leader>f <Plug>(key-fzf)
        xmap <Leader>f <Plug>(key-fzf)
        " coc-git
        " navigate conflicts of current buffer
        nmap [g <Plug>(coc-git-prevconflict)
        nmap ]g <Plug>(coc-git-nextconflict)
        " show commit contains current position
        nmap <silent> <Plug>(key-git)bc <Plug>(coc-git-commit)
    " }

    " Note: (cebrusfs) change from `[g` to `[d`
    " Use `[d` and `]d` to navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list
    nmap <silent> [d <Plug>(coc-diagnostic-prev)
    nmap <silent> ]d <Plug>(coc-diagnostic-next)

    " Note: (cebrusfs) changed mapping
    " GoTo code navigation.
    nmap <silent> <Plug>(key-goto)d <Plug>(coc-definition)
    nmap <silent> <Plug>(key-goto)t <Plug>(coc-type-definition)
    nmap <silent> <Plug>(key-goto)i <Plug>(coc-implementation)
    nmap <silent> <Plug>(key-goto)r <Plug>(coc-references)

    " Use K to show documentation in preview window
    nnoremap <silent> K :call ShowDocumentation()<CR>

    function! ShowDocumentation()
      if CocAction('hasProvider', 'hover')
        call CocActionAsync('doHover')
      else
        call feedkeys('K', 'in')
      endif
    endfunction

    " coc-highlight:
    " Highlight the symbol and its references when holding the cursor
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Symbol renaming
    nmap <leader>rn <Plug>(coc-rename)

    " Note: (cebrusfs) changed mapping
    " Formatting selected code.
    xmap <leader>=  <Plug>(coc-format-selected)
    nmap <leader>=  <Plug>(coc-format)

    augroup mygroup
      autocmd!
      " Setup formatexpr specified filetype(s)
      autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
      " Update signature help on jump placeholder
      autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
    augroup end

    " Applying code actions to the selected code block
    " Example: `<leader>aap` for current paragraph
    xmap <leader>a  <Plug>(coc-codeaction-selected)
    nmap <leader>a  <Plug>(coc-codeaction-selected)

    " Remap keys for applying code actions at the cursor position
    nmap <leader>ac  <Plug>(coc-codeaction-cursor)
    " Remap keys for apply code actions affect whole buffer
    nmap <leader>as  <Plug>(coc-codeaction-source)
    " Apply the most preferred quickfix action to fix diagnostic on the current line
    nmap <leader>qf  <Plug>(coc-fix-current)

    " Remap keys for applying refactor code actions
    nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
    xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
    nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)

    " Run the Code Lens action on the current line
    nmap <leader>cl  <Plug>(coc-codelens-action)

    " FIXME: do I need this?
    " Map function and class text objects
    " NOTE: Requires 'textDocument.documentSymbol' support from the language server
    xmap if <Plug>(coc-funcobj-i)
    omap if <Plug>(coc-funcobj-i)
    xmap af <Plug>(coc-funcobj-a)
    omap af <Plug>(coc-funcobj-a)
    xmap ic <Plug>(coc-classobj-i)
    omap ic <Plug>(coc-classobj-i)
    xmap ac <Plug>(coc-classobj-a)
    omap ac <Plug>(coc-classobj-a)

    " Remap <C-f> and <C-b> to scroll float windows/popups
    nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
    inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
    vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
    vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"

    " Note: (cebrusfs) changed mapping
    " Use <leader>s for selections ranges.
    " Requires 'textDocument/selectionRange' support of language server
    nmap <silent> <leader>s <Plug>(coc-range-select)
    xmap <silent> <leader>s <Plug>(coc-range-select)

    " Add `:Format` command to format current buffer
    command! -nargs=0 Format :call CocActionAsync('format')

    " Add `:Fold` command to fold current buffer
    command! -nargs=? Fold :call     CocAction('fold', <f-args>)

    " Add `:OR` command for organize imports of the current buffer
    command! -nargs=0 OR   :call     CocActionAsync('runCommand', 'editor.action.organizeImport')

    " Add (Neo)Vim's native statusline support
    " NOTE: Please see `:h coc-status` for integrations with external plugins that
    " provide custom statusline: lightline.vim, vim-airline
    set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

    " Mappings for CoCList
    " Show all diagnostics
    nnoremap <silent><nowait> <leader>a  :<C-u>CocList diagnostics<cr>
    " Manage extensions
    nnoremap <silent><nowait> <leader>e  :<C-u>CocList extensions<cr>
    " Show commands
    nnoremap <silent><nowait> <leader>c  :<C-u>CocList commands<cr>
    " Find symbol of current document
    nnoremap <silent><nowait> <leader>o  :<C-u>CocList outline<cr>
    " Search workspace symbols
    nnoremap <silent><nowait> <leader>s  :<C-u>CocList -I symbols<cr>
    " Do default action for next item
    nnoremap <silent><nowait> <leader>]  :<C-u>CocNext<CR>
    " Do default action for previous item
    nnoremap <silent><nowait> <leader>[  :<C-u>CocPrev<CR>
    " Resume latest coc list
    nnoremap <silent><nowait> <leader>p  :<C-u>CocListResume<CR>
endif
" }
" Fzf {
    Plug '~/.dotfiles/modules/fzf'

    " Git
    nnoremap <silent> <Plug>(key-git)s      :<C-u>CocCommand fzf-preview.GitStatus<CR>
    nnoremap <silent> <Plug>(key-git)a      :<C-u>CocCommand fzf-preview.GitActions<CR>
    " " Search in git commits
    " nnoremap <Leader>c :FZFBCommits<CR>

    " Search in current buffer
    nnoremap <silent> <Leader>/             :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
    nnoremap <silent> <Leader><Space>/      :<C-u>CocCommand fzf-preview.Lines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>
    " Search in opened buffer
    nnoremap <silent> <Leader>.             :<C-u>CocCommand fzf-preview.BufferLines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'"<CR>
    nnoremap <silent> <Leader><Space>.      :<C-u>CocCommand fzf-preview.BufferLines --add-fzf-arg=--no-sort --add-fzf-arg=--query="'<C-r>=expand('<cword>')<CR>"<CR>

    " Search file name
    nnoremap <silent> <Plug>(key-fzf)o      :<C-u>CocCommand fzf-preview.FromResources buffer project_mru project git<CR>
    nnoremap <silent> <Plug>(key-fzf)ls     :<C-u>CocCommand fzf-preview.FromResources directory<CR>

    " Search file contents
    nnoremap <silent> <Leader>r             :<C-u>CocCommand fzf-preview.ProjectGrep<Space>
    nnoremap <silent> <Leader><Space>r      :<C-u>CocCommand fzf-preview.ProjectGrep<Space><C-r>=expand('<cword>')<CR><CR>
    xnoremap <silent> <Leader>r             "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"<CR>

    nnoremap <silent> <Plug>(key-fzf)qf     :<C-u>CocCommand fzf-preview.QuickFix<CR>
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
    Plug 'ShikChen/osc52.vim'
    vnoremap Y y:call SendViaOSC52(getreg('"'))<CR>
" }

call plug#end()
" }


" Colorscheme settings {
    " True-color support
    if (has("termguicolors"))
        set termguicolors
    endif

    " Fallback for vim
    silent! colorscheme codedark

    " Load lua to setup the colorscheme on neovim
    silent! lua require('config')
    " Disable nvim-tree background color (already in lua config)
    " let g:vscode_disable_nvimtree_bg = v:true
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
            \ nnoremap <buffer> <Leader>p
            \ :w<CR>
            \ :!RUST_BACKTRACE=1 cargo run<CR>
autocmd Filetype rust
            \ nnoremap <buffer> <Leader>c
            \ :w<CR>
            \ :!cargo check<CR>
" }
