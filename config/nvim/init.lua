-- vim: ts=4 sts=4 sw=4 et

-- Resolve shared Vim defaults relative to the literal path used to load this
-- file. Keep this at top level: expand("<sfile>") is script-local and becomes
-- ambiguous in later callbacks.
local nvim_dir = vim.fn.expand("<sfile>:p:h")
local common_vim = vim.fn.fnamemodify(nvim_dir .. "/../vim/common.vim", ":p")
if vim.fn.filereadable(common_vim) == 1 then
    vim.cmd.source(vim.fn.fnameescape(common_vim))
else
    vim.notify("Missing shared Vim config: " .. common_vim, vim.log.levels.WARN)
end

-- Host providers are Neovim-only startup policy. Set them before any provider
-- checks so common.vim stays limited to shared Vim-compatible defaults.
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Neovim-only UI defaults live here; shared Vim-compatible defaults stay in
-- common.vim so the two editors do not drift for basic editing behavior.
vim.o.laststatus = 2
vim.opt.completeopt:append({ "menuone", "noselect", "popup" })

-- Clipboard routing:
-- `clipboard^=unnamed,unnamedplus` in common.vim changes the 'clipboard'
-- option so normal y/p use the system registers. `g:clipboard` is a different
-- Neovim provider override; leave it alone when built-in detection is enough.
-- * Local macOS/no SSH: no override; Neovim auto-selects pbcopy/pbpaste.
-- * SSH without tmux: force the built-in OSC52 provider because Neovim's
--   automatic OSC52 fallback only runs when the 'clipboard' option is empty,
--   and common.vim intentionally makes it non-empty.
-- * SSH + tmux -CC: no override; Neovim's tmux provider is the same path, and
--   iTerm2 can mirror the tmux paste buffer. tmux exposes -CC as
--   #{client_control_mode}=1, but this config does not need a runtime branch.
-- * SSH + tmux not -CC: no override; Neovim writes with `tmux load-buffer -w`
--   on tmux 3.2+, then tmux publishes via set-clipboard/Ms/OSC52 if configured.
--   Direct OSC52 from inside the pane is avoided because tmux's default
--   set-clipboard=external blocks pane apps from setting the clipboard.
-- Paste uses the selected provider too; iTerm2/terminal/tmux policy controls
-- whether OSC52 clipboard reads are allowed.
if (vim.env.SSH_TTY or vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT) and not vim.env.TMUX then
    vim.g.clipboard = "osc52"
end

local function gh(repo)
    return { src = "https://github.com/" .. repo }
end

-- Keep the old Neovim plugin surface installed first. Replacement rationale
-- lives beside each migrated plugin or module so it stays close to behavior.
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

" Native gc/gcc covers the Neovim comment workflow. Lua below keeps the old
" <Bslash> alias and restores armasm's '@' delimiter via 'commentstring'.

" Pandoc URL conceal keeps prose buffers readable.
let g:pandoc#syntax#conceal#urls = 1
]=])

-- `vim.pack` uses Neovim's native package layout. Keep the old dependency
-- surface during migration; modern replacements are called out in comments so
-- behavior can be swapped one workflow at a time.
local pack_specs = {
    -- Mini is adopted one small module at a time. The mini review matched this
    -- config's bias: small modules are good swaps; picker/files/git change core
    -- workflow. Adopted modules are trailspace, align, and jump2d;
    -- diff/files/pick/git still need workflow-specific review before replacing larger tools.
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
    -- Keep fzf-lua for fd/rg search with side-by-side previews. mini.pick is
    -- not equivalent for preview-heavy file and grep exploration.
    gh("ibhagwan/fzf-lua"),
    -- gitsigns keeps the richer hunk workflow. mini.diff is a candidate only
    -- if number-column hunks are worth trading off those actions.
    gh("lewis6991/gitsigns.nvim"),

    -- Editing/navigation muscle memory. Fugitive stays for repo/index status;
    -- mini.git is buffer-focused. Native gc/gcc now covers commenting with the
    -- old <Bslash> alias below. EasyAlign moved to mini.align.
    gh("tpope/vim-fugitive"),
    gh("sickill/vim-pasta"),
    -- mini.files uses a popup workflow; this keeps the existing tree toggle
    -- until file browsing is intentionally redesigned.
    gh("preservim/nerdtree"),
    gh("tpope/vim-endwise"),
    gh("vim-pandoc/vim-pandoc"),
    gh("vim-pandoc/vim-pandoc-syntax"),

    -- Niche filetypes. Remote copy is handled by the
    -- provider routing above; visual Y remains an explicit OSC52 fallback.
    gh("ShikChen/mojom.vim"),
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

-- Native commenting keeps the built-in gc/gcc mapping available while
-- preserving the old <Bslash> muscle memory. armasm has no default
-- 'commentstring', so restore the '@' delimiter previously owned by
-- NERDCommenter.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "armasm",
    callback = function()
        vim.bo.commentstring = "@ %s"
    end,
})
vim.keymap.set("n", "<Bslash>", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("x", "<Bslash>", "gc", { remap = true, desc = "Toggle comment" })

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

local ok_mini_align, mini_align = pcall(require, "mini.align")
if ok_mini_align then
    -- mini.align is the closest EasyAlign replacement. Keep <Leader>- as the
    -- primary muscle-memory entry, but default it to preview so alignment can
    -- be inspected before <CR> applies the edit.
    mini_align.setup({
        mappings = {
            start = "<Leader>_",
            start_with_preview = "<Leader>-",
        },
    })
end

local ok_mini_jump2d, mini_jump2d = pcall(require, "mini.jump2d")
if ok_mini_jump2d then
    mini_jump2d.setup({
        mappings = {
            start_jumping = "<Leader><Leader>",
        },
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
-- harper_ls replaces vim-grammarous for prose diagnostics. Its nvim-lspconfig
-- defaults cover Markdown plus Harper's comments-only programming filetypes.
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
            "harper_ls",
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
