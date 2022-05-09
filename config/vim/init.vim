" vim: set ts=4 ts=4 sts=4 et foldmarker={,} foldlevel=0 foldmethod=marker:

scriptencoding utf-8

" General {
    set nocompatible

    " Store a ton of history (default is 20)
    set history=1000

    " Auto read when file is changed from outside
    set autoread

    " Directory of swap files
    set directory^=~/.vimfiles/swap,/tmp2

    " Directory of undo files
    set undodir^=~/.vimfiles/undo,/tmp2
    set undofile

    " clipboard: Use both * and + registers clipboard buffer. (OSX, Windows,
    " Linux)
    " Known issue: https://github.com/neovim/neovim/issues/1822
    set clipboard^=unnamed,unnamedplus

    " Encoding
    set fileencoding=utf-8
    set fileencodings=ucs-bom,utf-8,big5,cp936,gb18030,latin1
" }

" User Interface {
    set number            " line number

    set virtualedit=onemore             " Allow for cursor beyond last character

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


call plug#begin() " {

" Color Scheme {
    Plug 'jacoborus/tender.vim'
    Plug 'tomasiser/vim-code-dark'
    Plug 'Mofiqul/vscode.nvim'
" }

" vim-airline: Powerful status bar {
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'

    " Note: airline integration with another vim plugins
    "   git-branch: tpope/vim-fugitive
    "   git-status: coc-git

    let g:airline_theme = 'tender'

    " Enable power line fonts
    let g:airline_powerline_fonts = 1
" }

" vim-indent-guides: Show indent space and tab with colors {
    Plug 'nathanaelkane/vim-indent-guides'

    " FIXME: color
    let g:indent_guides_auto_colors=0
    autocmd VimEnter,Colorscheme * highlight IndentGuidesOdd  guibg=grey30   ctermbg=234
    autocmd VimEnter,Colorscheme * highlight IndentGuidesEven guibg=grey15   ctermbg=236
    let g:indent_guides_guide_size=1
    let g:indent_guides_enable_on_vim_startup=1
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

" coc: Intellisense engine for Vim8 & Neovim, full language server protocol support as VSCode {
    Plug 'neoclide/coc.nvim', {'branch': 'release'}

    " Programming language extensions
    let g:coc_global_extensions = [
        "\ C/C++/Objective-C
        \'coc-clangd',
        "\ Python3
        \'coc-pyright',
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

    " ==============================================================
    " Offcial references settings of coc
    " https://github.com/neoclide/coc.nvim#example-vim-configuration
    " ==============================================================

    " TextEdit might fail if hidden is not set.
    set hidden

    " Some servers have issues with backup files, see #649.
    set nobackup
    set nowritebackup

    " Give more space for displaying messages.
    set cmdheight=2

    " Having longer updatetime (default is 4000 ms = 4 s) leads to noticeable
    " delays and poor user experience.
    set updatetime=200

    " Don't pass messages to |ins-completion-menu|.
    set shortmess+=c

    " Note: Disabled
    " Always show the signcolumn, otherwise it would shift the text each time
    " diagnostics appear/become resolved.
    " if has("patch-8.1.1564")
      " " Recently vim can merge signcolumn and number column into one
      " set signcolumn=number
    " else
      " set signcolumn=yes
    " endif

    " Use tab and shift-tab to go downward and upward in completion list.
    " Use tab for trigger completion with characters ahead and navigate.
    inoremap <silent><expr> <TAB>
          \ pumvisible() ? "\<C-n>" :
          \ <SID>check_back_space() ? "\<TAB>" :
          \ coc#refresh()
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

    function! s:check_back_space() abort
      let col = col('.') - 1
      return !col || getline('.')[col - 1]  =~# '\s'
    endfunction

    " Note: manually trigger completion is not useful, disabled.
    " Use <c-space> to trigger completion.
    " if has('nvim')
      " inoremap <silent><expr> <c-space> coc#refresh()
    " else
      " inoremap <silent><expr> <c-@> coc#refresh()
    " endif

    " Note: Disabled
    " Make <CR> auto-select the first completion item and notify coc.nvim to
    " format on enter, <cr> could be remapped by other vim plugin
    " inoremap <silent><expr> <cr> pumvisible() ? coc#_select_confirm()
                                  " \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

    nmap [ <Plug>(key-prev)
    nmap ] <Plug>(key-next)
    nmap <Leader>j <Plug>(key-goto)
    nmap <Leader>l <Plug>(key-list)
    nmap <Leader>g <Plug>(key-git)

    nmap <Leader>f <Plug>(key-fzf)
    xmap <Leader>f <Plug>(key-fzf)

    " Navigate diagnostics
    " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
    nmap <silent> <Plug>(key-prev)d <Plug>(coc-diagnostic-prev)
    nmap <silent> <Plug>(key-next)d <Plug>(coc-diagnostic-next)

    " GoTo code navigation.
    nmap <silent> <Plug>(key-goto)d <Plug>(coc-definition)
    nmap <silent> <Plug>(key-goto)t <Plug>(coc-type-definition)
    nmap <silent> <Plug>(key-goto)i <Plug>(coc-implementation)
    nmap <silent> <Plug>(key-goto)r <Plug>(coc-references)

    " Symbol renaming.
    nmap <Leader>rn <Plug>(coc-rename)

    " Use K to show documentation in preview window.
    nnoremap <silent> K :call <SID>show_documentation()<CR>
    function! s:show_documentation()
      if (index(['vim','help'], &filetype) >= 0)
        execute 'h '.expand('<cword>')
      elseif (coc#rpc#ready())
        call CocActionAsync('doHover')
      else
        execute '!' . &keywordprg . " " . expand('<cword>')
      endif
    endfunction

    " coc-highlight:
    " Highlight the symbol and its references when holding the cursor.
    autocmd CursorHold * silent call CocActionAsync('highlight')

    " Formatting selected code.
    xmap <Leader>=  <Plug>(coc-format-selected)
    nmap <Leader>=  <Plug>(coc-format)

    " Applying codeAction to the selected region.
    " Example: `<Leader>aap` for current paragraph
    xmap <Leader>a  <Plug>(coc-codeaction-selected)
    nmap <Leader>a  <Plug>(coc-codeaction-selected)

    " Remap keys for applying codeAction to the current buffer.
    nmap <Leader>ac  <Plug>(coc-codeaction)

    " Apply AutoFix to problem on the current line.
    nmap <Leader>qf  <Plug>(coc-fix-current)

    " FIXME: do I need this?
    " Map function and class text objects
    " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
    " xmap if <Plug>(coc-funcobj-i)
    " omap if <Plug>(coc-funcobj-i)
    " xmap af <Plug>(coc-funcobj-a)
    " omap af <Plug>(coc-funcobj-a)
    " xmap ic <Plug>(coc-classobj-i)
    " omap ic <Plug>(coc-classobj-i)
    " xmap ac <Plug>(coc-classobj-a)
    " omap ac <Plug>(coc-classobj-a)

    " Note: Use page-up/page-down instead. Disabled.
    " Remap <C-f> and <C-b> for scroll float windows/popups.
    " if has('nvim-0.4.0') || has('patch-8.2.0750')
      " nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
      " nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
      " inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
      " inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
      " vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
      " vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
    " endif

    " Use <Leader>s for selections ranges.
    " Requires 'textDocument/selectionRange' support of language server.
    nmap <silent> <Leader>s <Plug>(coc-range-select)
    xmap <silent> <Leader>s <Plug>(coc-range-select)

    " Mappings for CoCList
    " Show all diagnostics.
    nnoremap <silent><nowait> <Plug>(key-list)d  :<C-u>CocList diagnostics<cr>
    " Manage extensions.
    nnoremap <silent><nowait> <Plug>(key-list)e  :<C-u>CocList extensions<cr>
    " Show commands.
    nnoremap <silent><nowait> <Plug>(key-list)c  :<C-u>CocList commands<cr>
    " Find symbol of current document.
    nnoremap <silent><nowait> <Plug>(key-list)o  :<C-u>CocList outline<cr>
    " Search workLeader symbols.
    nnoremap <silent><nowait> <Plug>(key-list)s  :<C-u>CocList -I symbols<cr>
    " Resume latest coc list.
    nnoremap <silent><nowait> <Plug>(key-list)l  :<C-u>CocListResume<CR>

    " Do default action for next item.
    " nnoremap <silent><nowait> <Leader>j  :<C-u>CocNext<CR>
    " Do default action for previous item.
    " nnoremap <silent><nowait> <Leader>k  :<C-u>CocPrev<CR>

    " coc-git
    " navigate conflicts of current buffer
    nmap <Plug>(key-prev)g <Plug>(coc-git-prevconflict)
    nmap <Plug>(key-next)g <Plug>(coc-git-nextconflict)
    " show commit contains current position
    nmap <silent> <Plug>(key-git)c <Plug>(coc-git-commit)
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
    xnoremap <silent> <Leader><Space>r      "sy:CocCommand   fzf-preview.ProjectGrep<Space>-F<Space>"<C-r>=substitute(substitute(@s, '\n', '', 'g'), '/', '\\/', 'g')<CR>"

    nnoremap <silent> <Plug>(key-fzf)qf     :<C-u>CocCommand fzf-preview.QuickFix<CR>
" }
" vim-fugitive: git integration {
    Plug 'tpope/vim-fugitive'

    nnoremap <silent> <Plug>(key-git)s      :<C-u>Gstatus<CR>
    nnoremap <silent> <Plug>(key-git)d      :<C-u>Gdiff<CR>
    nnoremap <silent> <Plug>(key-git)b      :<C-u>Git blame<CR>
    nnoremap <silent> <Plug>(key-git)m      :<C-u>Git mergetool<CR>
" }

" vim-easy-align: align tool {
    Plug 'junegunn/vim-easy-align'

    xmap <Leader>- <Plug>(EasyAlign)
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

" local-vimrc 'lvimrc': {
    Plug 'coquelicot/local-vimrc'
" }

" FIXME
" vim-easymotion: Fast jump {
    " Plug 'easymotion/vim-easymotion'
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

call plug#end() " }


" Colorscheme settings {
    " True-color support
    if (has("termguicolors"))
        set termguicolors
    endif

    " Fallback for vim
    silent! colorscheme codedark

    " For dark theme
    let g:vscode_style = "dark"
    " Disable nvim-tree background color
    " let g:vscode_disable_nvimtree_bg = v:true

    silent! colorscheme vscode

    " Remove the backgroud color of sign column
    highlight clear SignColumn ctermbg guibg
" }

" Wrap the long lines and highlight wrap limit {
    set colorcolumn=+1
    " FIXME: color
    highlight ColorColumn guibg=firebrick4
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
            \ :!python -W always -tt %<CR>

autocmd Filetype ruby
            \ nnoremap <buffer> <Leader>p
            \ :w<CR>
            \ :!ruby %<CR>

autocmd Filetype sh
            \ nnoremap <buffer> <Leader>p
            \ :w<CR>
            \ :!sh %<CR>
" }
