-- vim: ts=4 sts=4 sw=4 et

-- Resolve shared Vim defaults relative to THIS file rather than stdpath: the
-- headless CI check loads init.lua directly with no ~/.config/nvim symlink, so a
-- stdpath lookup would miss common.vim. debug.getinfo is the standard way to get
-- the running script path (works under both :source and dofile); resolve()
-- collapses the install symlink so the sibling ../vim tree (linked as ~/.vim, not
-- ~/.config/vim) stays reachable.
local this_file = debug.getinfo(1, "S").source:sub(2)
local common_vim = vim.fn.fnamemodify(vim.fn.resolve(this_file) .. "/../../vim/common.vim", ":p")
if vim.fn.filereadable(common_vim) == 1 then
    vim.cmd.source(vim.fn.fnameescape(common_vim))
else
    vim.notify("Missing shared Vim config: " .. common_vim, vim.log.levels.WARN)
end

-- Neovim-only UI defaults live here; shared Vim-compatible defaults stay in
-- common.vim so the two editors do not drift for basic editing behavior.
vim.o.laststatus = 2
vim.opt.completeopt:append({ "menuone", "noselect", "popup" })

local function gh(repo)
    return { src = "https://github.com/" .. repo }
end

-- Keep the old Neovim plugin surface installed first. Review
-- docs/nvim-plugin-review.md before removing or replacing each dependency.
vim.cmd([=[
" Statusline parity: airline/tender was the previously enabled stack.
" lualine, mini.statusline, or native statusline are better Neovim candidates,
" but replacing this needs visual parity checks instead of a migration drive-by.
let g:airline_theme = 'tender'
let g:airline_powerline_fonts = 1

" Keep the old filetype exceptions. HTML gets a custom start/end pattern so
" void tags are not treated as paired tags; CSS/C/C++/Python stay disabled
" because their syntax/highlighting already made rainbow noisy.
let g:rainbow_active = 1
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

" Keep NERDCommenter for <Bslash> muscle memory and the armasm '@' delimiter.
" Native gc/gcc can replace this once commentstring parity is verified.
let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDCommentEmptyLines = 1
let g:NERDToggleCheckAllLines = 1
let g:NERDCustomDelimiters = {
    \'armasm': {'left': '@'},
\}

" Pandoc URL conceal keeps prose buffers readable. Grammarous checks comments
" only in source files, while help/markdown remain full-document prose checks.
let g:pandoc#syntax#conceal#urls = 1
let g:grammarous#default_comments_only_filetypes = {
    \ '*' : 1,
    \ 'help' : 0,
    \ 'markdown' : 0,
    \ }
]=])

-- `vim.pack` uses Neovim's native package layout. Keep the old dependency
-- surface during migration; modern replacements are called out in comments so
-- behavior can be swapped one workflow at a time.
local pack_specs = {
    -- Mini is adopted one small module at a time. Good candidates: trailspace,
    -- align, statusline, comment, diff. Keep picker/files/git replacements
    -- behind workflow checks because fzf-lua/fugitive/NERDTree differ sharply.
    gh("nvim-mini/mini.nvim"),

    -- Themes and statusline.
    gh("tomasiser/vim-code-dark"),
    gh("Mofiqul/vscode.nvim"),
    gh("vim-airline/vim-airline"),
    gh("jacoborus/tender.vim"),

    -- Indent and whitespace. `vim-indent-guides` is kept for parity; ibl below
    -- is the active Neovim indent-guide implementation. mini.trailspace handles
    -- Error-colored trailing whitespace.
    gh("preservim/vim-indent-guides"),
    gh("lukas-reineke/indent-blankline.nvim"),
    gh("luochen1990/rainbow"),

    -- Programming stack. Native vim.lsp.config/enable is the control plane;
    -- nvim-cmp remains for buffer/path/cmdline completion polish.
    gh("neovim/nvim-lspconfig"),
    gh("mason-org/mason.nvim"),
    gh("mason-org/mason-lspconfig.nvim"),
    gh("hrsh7th/cmp-nvim-lsp"),
    gh("hrsh7th/cmp-buffer"),
    gh("hrsh7th/cmp-path"),
    gh("hrsh7th/cmp-cmdline"),
    gh("hrsh7th/nvim-cmp"),
    gh("ibhagwan/fzf-lua"),
    gh("lewis6991/gitsigns.nvim"),

    -- Editing/navigation muscle memory. Native gc/gcc and netrw/fzf-lua cover
    -- parts of this, but not the old mappings and edge-case behavior yet.
    gh("tpope/vim-fugitive"),
    gh("junegunn/vim-easy-align"),
    gh("sickill/vim-pasta"),
    gh("preservim/nerdtree"),
    gh("preservim/nerdcommenter"),
    gh("tpope/vim-endwise"),
    gh("vim-pandoc/vim-pandoc"),
    gh("vim-pandoc/vim-pandoc-syntax"),

    -- Niche filetypes, jump/prose tools, and remote copy. Native OSC52 is a
    -- possible follow-up after environment checks, especially over SSH and tmux.
    gh("ShikChen/mojom.vim"),
    gh("easymotion/vim-easymotion"),
    gh("rhysd/vim-grammarous"),
    gh("ShikChen/osc52.vim"),
    { src = "https://gn.googlesource.com/gn", name = "gn" },
}

-- NVIM_SKIP_PACK keeps headless syntax checks offline and independent of
-- installed plugin state.
if vim.pack and vim.env.NVIM_SKIP_PACK ~= "1" then
    vim.pack.add(pack_specs, { confirm = false, load = true })
elseif not vim.pack then
    vim.notify("vim.pack requires Neovim 0.12+", vim.log.levels.WARN)
end

if vim.pack then
    -- TODO(nvim 0.13): drop this fallback after :packdel ++all is available
    -- on every machine that runs ./update.
    vim.api.nvim_create_user_command("PackClean", function()
        if vim.env.NVIM_SKIP_PACK == "1" then
            vim.notify("PackClean is disabled when NVIM_SKIP_PACK=1", vim.log.levels.WARN)
            return
        end

        local inactive = vim.iter(vim.pack.get())
            :filter(function(plugin)
                return not plugin.active
            end)
            :map(function(plugin)
                return plugin.spec.name
            end)
            :totable()

        if #inactive == 0 then
            vim.notify("No inactive vim.pack plugins to remove")
            return
        end

        vim.pack.del(inactive, { force = true })
    end, { desc = "Remove vim.pack plugins no longer declared by this config" })
end

-- The GN repo keeps its Vim runtime under misc/vim instead of the package
-- root, so packadd alone does not expose its syntax files.
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site/pack/core/opt/gn/misc/vim")

-- Preserve old mappings after packadd so plugin-defined <Plug> targets exist.
vim.keymap.set("n", "<S-Tab>", "<cmd>NERDTreeToggle<CR>", { desc = "Toggle NERDTree" })
vim.keymap.set("n", "<Bslash>", "<Plug>NERDCommenterToggle", { remap = true, desc = "Toggle comment" })
vim.keymap.set("x", "<Bslash>", "<Plug>NERDCommenterToggle", { remap = true, desc = "Toggle comment" })
vim.keymap.set("x", "Y", [[y:call SendViaOSC52(getreg('"'))<CR>]], { desc = "Yank via OSC52" })

-- vscode.nvim was the active Neovim colorscheme. Fall back to default instead
-- of codedark because codedark is kept only as legacy/Vim parity.
local ok_vscode, vscode = pcall(require, "vscode")
if ok_vscode then
    vscode.setup({
        transparent = true,
        italic_comments = true,
        underline_links = true,
    })
    vim.cmd.colorscheme("vscode")
else
    vim.cmd.colorscheme("default")
end

local ok_mini_trailspace, mini_trailspace = pcall(require, "mini.trailspace")
if ok_mini_trailspace then
    mini_trailspace.setup()

    local function link_mini_trailspace()
        vim.api.nvim_set_hl(0, "MiniTrailspace", { link = "Error" })
    end

    link_mini_trailspace()
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = link_mini_trailspace,
    })
end

-- Show diagnostic detail only on the current line to keep dense buffers calm.
vim.diagnostic.config({
    virtual_lines = {
        current_line = true,
    },
})

-- Apply completion capabilities through the native LSP config chain. nvim-cmp
-- augments the client only when installed; otherwise builtin LSP still works.
local capabilities = vim.lsp.protocol.make_client_capabilities()

local ok_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp_nvim_lsp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

vim.lsp.config("*", {
    capabilities = capabilities,
})

-- Keep nvim-cmp for path, buffer, and cmdline sources. Native LSP completion is
-- a good fallback but does not replace those workflow details yet.
local ok_cmp, cmp = pcall(require, "cmp")
if ok_cmp then
    cmp.setup({
        snippet = {
            expand = function(args)
                vim.snippet.expand(args.body)
            end,
        },
        window = {},
        mapping = cmp.mapping.preset.insert({
            ["<C-b>"] = cmp.mapping.scroll_docs(-4),
            ["<C-f>"] = cmp.mapping.scroll_docs(4),
            ["<C-Space>"] = cmp.mapping.complete(),
            ["<C-e>"] = cmp.mapping.abort(),
            ["<CR>"] = cmp.mapping.confirm({ select = true }),
        }),
        sources = cmp.config.sources({
            { name = "nvim_lsp" },
            {
                name = "path",
                option = {
                    trailing_slash = true,
                },
            },
        }, {
            { name = "buffer" },
        }),
    })

    cmp.setup.cmdline({ "/", "?" }, {
        mapping = cmp.mapping.preset.cmdline(),
        sources = {
            { name = "buffer" },
        },
    })

    cmp.setup.cmdline(":", {
        mapping = cmp.mapping.preset.cmdline(),
        sources = cmp.config.sources({
            { name = "path" },
        }, {
            { name = "cmdline" },
        }),
        matching = { disallow_symbol_nonprefix_matching = false },
    })
end

-- When nvim-cmp is intentionally skipped, use Neovim's builtin LSP completion
-- instead of leaving attached servers with only manual omnifunc completion.
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        if ok_cmp then
            return
        end
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

-- Mason still owns server installation. mason-lspconfig bridges installed
-- servers to nvim-lspconfig configs and lets Neovim's native enable path attach
-- them automatically.
local ok_mason, mason = pcall(require, "mason")
if ok_mason then
    mason.setup()
end

local ok_mason_lspconfig, mason_lspconfig = pcall(require, "mason-lspconfig")
if ok_mason_lspconfig then
    mason_lspconfig.setup({
        ensure_installed = {
            "clangd",
            "pyright",
            "solargraph",
            "ts_ls",
            "rust_analyzer",
            "bashls",
            "jsonls",
            "yamlls",
            "taplo",
            "lua_ls",
        },
        automatic_enable = true,
    })
end

-- gitsigns covers inline hunk state; fugitive mappings below stay for command
-- workflows like blame, diff, and mergetool.
local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
if ok_gitsigns then
    gitsigns.setup()
end

local ok_ibl, ibl = pcall(require, "ibl")
-- listchars stays for normal spacing visibility. Trailing whitespace is not a
-- listchar because mini.trailspace highlights it with the Error group instead.
vim.opt.list = true
vim.opt.listchars:append({ multispace = "." })
vim.opt.listchars:remove("space")
vim.opt.listchars:remove("trail")

if ok_ibl then
    ibl.setup()
end

-- Keep the old Git prefix stable. These are Git-backed commands even when the
-- repository is operated through jj outside the editor.
vim.keymap.set("n", "<Leader>g", "<Nop>", { desc = "Git prefix" })
vim.keymap.set("n", "<Leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
vim.keymap.set("n", "<Leader>gd", "<cmd>Gdiffsplit<CR>", { desc = "Git diff" })
vim.keymap.set("n", "<Leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<Leader>gm", "<cmd>Git mergetool<CR>", { desc = "Git mergetool" })

-- EasyAlign is still the smallest change for the existing alignment muscle
-- memory; native formatting and mini.align are separate workflow choices.
vim.keymap.set("x", "<Leader>-", "<Plug>(EasyAlign)", { remap = true, desc = "EasyAlign" })
vim.keymap.set("n", "<Leader>-", "<Plug>(EasyAlign)", { remap = true, desc = "EasyAlign" })

local ok_fzf, fzf = pcall(require, "fzf-lua")
if ok_fzf then
    fzf.setup({
        defaults = {
            file_ignore_patterns = { "node_modules", ".git", "__pycache__" },
        },
        files = {
            -- Prefer fd for file listing; it matches the repo-wide default tool
            -- preference and avoids shelling through slower generic find flows.
            fd_opts = "--color=never --type f --hidden --follow --exclude .git",
        },
        grep = {
            -- Keep ripgrep hidden-file coverage, but exclude rules remain the
            -- project's responsibility via .gitignore/.ignore.
            rg_opts = "--color=never --hidden --follow",
        },
    })

    -- fzf-lua keeps file, text, buffer, and help search on one picker stack.
    -- The current-word mapping is intentionally project-wide, not LSP-scoped.
    vim.keymap.set("n", "<Leader>fo", fzf.files, { desc = "Find files" })
    vim.keymap.set("n", "<Leader>r", fzf.live_grep, { desc = "Live grep in project" })
    vim.keymap.set("n", "<Leader><Space>r", function()
        fzf.live_grep({ search = vim.fn.expand("<cword>") })
    end, { desc = "Live grep current word in project" })
    vim.keymap.set("n", "<Leader>/", fzf.blines, { desc = "Search in current buffer" })
    vim.keymap.set("n", "<Leader>.", fzf.buffers, { desc = "Search in open buffers" })
    vim.keymap.set("n", "<Leader>fh", fzf.help_tags, { desc = "Help tags" })
end
