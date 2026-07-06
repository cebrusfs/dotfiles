-- vim: ts=4 sts=4 sw=4 et

-- Resolve shared Vim defaults relative to this file. `dofile()` does not set
-- <sfile> to the Lua chunk path, so use debug source and normalize symlinks.
local source = debug.getinfo(1, "S").source
local nvim_dir = source:sub(1, 1) == "@" and vim.fn.fnamemodify(source:sub(2), ":p:h") or vim.fn.expand("<sfile>:p:h")
local real_nvim_dir = (vim.uv or vim.loop).fs_realpath(nvim_dir)
if real_nvim_dir then
    nvim_dir = real_nvim_dir
end
local common_vim = vim.fn.fnamemodify(nvim_dir .. "/../vim/common.vim", ":p")
if vim.fn.filereadable(common_vim) == 1 then
    vim.cmd.source(vim.fn.fnameescape(common_vim))
else
    vim.notify("Missing shared Vim config: " .. common_vim, vim.log.levels.WARN)
end

-- Host providers are Neovim-only startup policy. Set them before any provider
-- checks so `common.vim` stays limited to shared Vim-compatible defaults.
vim.g.loaded_python3_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_node_provider = 0

-- Neovim-only UI defaults live here; shared Vim-compatible defaults stay in
-- `common.vim` so the two editors do not drift. The native statusline defined
-- there is the Vim and no-plugin fallback; airline overrides it in Neovim.
vim.opt.completeopt:append({ "menuone", "noselect", "popup" })

-- Clipboard routing:
-- `clipboard^=unnamed,unnamedplus` in `common.vim` changes the 'clipboard'
-- option so normal y/p use the system registers. `g:clipboard` is a different
-- Neovim provider override; leave it alone when built-in detection is enough.
-- * Local macOS/no SSH: no override; Neovim selects `pbcopy`/`pbpaste`.
-- * SSH without tmux: force the built-in `OSC52` provider because Neovim's
--   automatic `OSC52` fallback only runs when the 'clipboard' option is empty,
--   and `common.vim` intentionally makes it nonempty.
-- * SSH + tmux -CC: no override; Neovim's tmux provider is the same path, and
--   iTerm2 can mirror the tmux paste buffer. tmux exposes -CC as
--   #{client_control_mode}=1, but this config does not need a runtime branch.
-- * SSH + tmux not -CC: no override; Neovim writes with `tmux load-buffer -w`
--   on tmux 3.2+, then tmux publishes via set-clipboard/Ms/`OSC52` if configured.
--   Direct `OSC52` from inside the pane is avoided because tmux's default
--   set-clipboard=external blocks pane apps from setting the clipboard.
-- Paste uses the selected provider too; iTerm2/terminal/tmux policy controls
-- whether `OSC52` clipboard reads are allowed.
if (vim.env.SSH_TTY or vim.env.SSH_CONNECTION or vim.env.SSH_CLIENT) and not vim.env.TMUX then
    vim.g.clipboard = "osc52"
end

local function gh(repo)
    return { src = "https://github.com/" .. repo }
end

vim.cmd([=[
" Airline/tender provides the Neovim statusline; the shared native statusline
" remains the fallback until its visual parity is verified.
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
]=])

-- `vim.pack` uses Neovim's native package layout. Missing plugins install at
-- the tracked lock-file revisions on startup; upgrades are intentional
-- `vim.pack.update()` runs. Rationale for keeping each plugin lives beside its
-- declaration or setup block so it stays close to behavior.
local pack_specs = {
    -- Mini provides the focused `trailspace`, `align`, and `jump2d` modules.
    -- Its diff/files/pick/git modules change core workflows and stay disabled.
    gh("nvim-mini/mini.nvim"),

    -- `vscode.nvim` is the active Neovim theme; airline/tender provides its
    -- statusline. Vim uses the native statusline in `common.vim`.
    gh("Mofiqul/vscode.nvim"),
    gh("vim-airline/vim-airline"),
    gh("jacoborus/tender.vim"),

    -- `indent-blankline.nvim` provides indent guides; `rainbow` colors delimiters.
    -- `mini.trailspace` handles Error-colored trailing whitespace.
    gh("lukas-reineke/indent-blankline.nvim"),
    gh("luochen1990/rainbow"),

    -- Programming stack. Native `vim.lsp.config`/`enable` is the control plane;
    -- `nvim-cmp` remains for buffer/path/cmdline completion polish.
    gh("neovim/nvim-lspconfig"),
    gh("mason-org/mason.nvim"),
    gh("mason-org/mason-lspconfig.nvim"),
    gh("hrsh7th/cmp-nvim-lsp"),
    gh("hrsh7th/cmp-buffer"),
    gh("hrsh7th/cmp-path"),
    gh("hrsh7th/cmp-cmdline"),
    gh("hrsh7th/nvim-cmp"),
    -- Keep `fzf-lua` for `fd`/`rg` search with side-by-side previews; NERDTree
    -- keeps the persistent tree toggle on <S-Tab>.
    gh("ibhagwan/fzf-lua"),
    -- `gitsigns` keeps passive hunk/sign state; fugitive stays for command
    -- workflows like status, blame, diff, and mergetool.
    gh("lewis6991/gitsigns.nvim"),

    -- Editing/navigation muscle memory. `vim-pasta` keeps block-context paste
    -- indentation; language-aware `end` insertion has no native equivalent.
    gh("tpope/vim-fugitive"),
    gh("sickill/vim-pasta"),
    gh("preservim/nerdtree"),
    gh("tpope/vim-endwise"),

    -- Mojom and GN provide syntax for Chromium-adjacent filetypes.
    gh("ShikChen/mojom.vim"),
    { src = "https://gn.googlesource.com/gn", name = "gn" },
}

local plugins_enabled = vim.o.loadplugins

-- Respect Neovim's plugin-loading switch so `--noplugin` or
-- `--cmd 'set noloadplugins'` can load-check this config without external
-- packages.
if vim.pack and plugins_enabled then
    vim.pack.add(pack_specs, { confirm = false, load = true })
elseif not vim.pack then
    vim.notify("vim.pack requires Neovim 0.12+", vim.log.levels.WARN)
end

if vim.pack then
    -- TODO(Neovim 0.13): drop this fallback once `:packdel ++all` is available
    -- on every machine that runs `./update`.
    vim.api.nvim_create_user_command("PackClean", function()
        if not vim.o.loadplugins then
            vim.notify("PackClean is disabled when 'loadplugins' is off", vim.log.levels.WARN)
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

-- The `GN` repo keeps its Vim runtime under misc/vim instead of the package
-- root, so `packadd` alone does not expose its syntax files.
vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site/pack/core/opt/gn/misc/vim")

-- Preserve old mappings after `packadd` so plugin-defined <Plug> targets exist.
vim.keymap.set("n", "<S-Tab>", "<cmd>NERDTreeToggle<CR>", { desc = "Toggle NERDTree" })

-- Native commenting keeps the built-in `gc`/`gcc` mapping available while
-- preserving the old <Bslash> muscle memory. `armasm` has no default
-- 'commentstring', so restore the '@' delimiter previously owned by
-- `NERDCommenter`.
vim.api.nvim_create_autocmd("FileType", {
    pattern = "armasm",
    callback = function()
        vim.bo.commentstring = "@ %s"
    end,
})
vim.keymap.set("n", "<Bslash>", "gcc", { remap = true, desc = "Toggle comment line" })
vim.keymap.set("x", "<Bslash>", "gc", { remap = true, desc = "Toggle comment" })

-- `vscode.nvim` is the active Neovim colorscheme; `codedark` stays Vim-only.
-- Fall back to the built-in default when plugins are disabled.
if plugins_enabled then
    local vscode = require("vscode")
    vscode.setup({
        transparent = true,
        italic_comments = true,
        underline_links = true,
    })
    vim.cmd.colorscheme("vscode")
else
    vim.cmd.colorscheme("default")
end

if plugins_enabled then
    local mini_trailspace = require("mini.trailspace")
    mini_trailspace.setup()

    local function link_mini_trailspace()
        vim.api.nvim_set_hl(0, "MiniTrailspace", { link = "Error" })
    end

    link_mini_trailspace()
    vim.api.nvim_create_autocmd("ColorScheme", {
        callback = link_mini_trailspace,
    })
end

if plugins_enabled then
    local mini_align = require("mini.align")
    -- `mini.align` is the closest `EasyAlign` replacement. Keep <Leader>- as the
    -- primary muscle-memory entry, but default it to preview so alignment can
    -- be inspected before <CR> applies the edit.
    mini_align.setup({
        mappings = {
            start = "<Leader>_",
            start_with_preview = "<Leader>-",
        },
    })
end

if plugins_enabled then
    local mini_jump2d = require("mini.jump2d")
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

-- Apply completion capabilities through the native LSP config chain. `nvim-cmp`
-- augments the client only when installed; otherwise builtin LSP still works.
local capabilities = vim.lsp.protocol.make_client_capabilities()

if plugins_enabled then
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

vim.lsp.config("*", {
    capabilities = capabilities,
})

-- Global Harper tweaks. `ToDoHyphen` rewrites `TODO` markers to a hyphenated
-- form, which is noise for code; turn it off and whitelist `TODO` through
-- `userDictPath` so the markers stay clean in every project. Proper nouns are
-- silenced with backticks at each call site instead.
vim.lsp.config("harper_ls", {
    settings = {
        ["harper-ls"] = {
            userDictPath = vim.fn.stdpath("config") .. "/harper-userdict.txt",
            linters = {
                ToDoHyphen = false,
            },
        },
    },
})

-- Keep `nvim-cmp` for path, buffer, and cmdline sources. Native LSP completion is
-- a good fallback but does not replace those workflow details yet.
local cmp_enabled = false
if plugins_enabled then
    local cmp = require("cmp")
    cmp_enabled = true
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

-- When plugin loading is disabled, use Neovim's builtin LSP completion instead
-- of leaving attached servers with only manual `omnifunc` completion.
vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(ev)
        if cmp_enabled then
            return
        end
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if client and client:supports_method("textDocument/completion") then
            vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
        end
    end,
})

-- Mason still owns server installation. `mason-lspconfig` bridges installed
-- servers to `nvim-lspconfig` configs and lets Neovim's native enable path attach
-- them automatically.
-- `harper_ls` replaces `vim-grammarous` for prose diagnostics. Its `nvim-lspconfig`
-- defaults cover Markdown plus Harper's comments-only programming filetypes.
if plugins_enabled then
    local mason = require("mason")
    mason.setup()
end

if plugins_enabled then
    local mason_lspconfig = require("mason-lspconfig")
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

-- `gitsigns` covers inline hunk state; fugitive mappings below stay for command
-- workflows like blame, diff, and `mergetool`.
if plugins_enabled then
    local gitsigns = require("gitsigns")
    gitsigns.setup()
end

-- `listchars` stays for normal spacing visibility. Trailing whitespace is not a
-- `listchar` because `mini.trailspace` highlights it with the Error group instead.
vim.opt.list = true
vim.opt.listchars:append({ multispace = "." })
vim.opt.listchars:remove("space")
vim.opt.listchars:remove("trail")

if plugins_enabled then
    local ibl = require("ibl")
    ibl.setup()
end

-- Keep the old Git prefix stable. These are Git-backed commands even when the
-- repository is operated through `jj` outside the editor.
vim.keymap.set("n", "<Leader>g", "<Nop>", { desc = "Git prefix" })
vim.keymap.set("n", "<Leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
vim.keymap.set("n", "<Leader>gd", "<cmd>Gdiffsplit<CR>", { desc = "Git diff" })
vim.keymap.set("n", "<Leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<Leader>gm", "<cmd>Git mergetool<CR>", { desc = "Git mergetool" })

if plugins_enabled then
    local fzf = require("fzf-lua")
    fzf.setup({
        defaults = {
            file_ignore_patterns = { "node_modules", ".git", "__pycache__" },
        },
        files = {
            -- Prefer `fd` for file listing; it matches the repo-wide default tool
            -- preference and avoids shelling through slower generic find flows.
            fd_opts = "--color=never --type f --hidden --follow --exclude .git",
        },
        grep = {
            -- Keep `ripgrep` hidden-file coverage, but exclude rules remain the
            -- project's responsibility via `.gitignore`/`.ignore`.
            rg_opts = "--color=never --hidden --follow",
        },
    })

    -- `fzf-lua` keeps file, text, buffer, and help search on one picker stack.
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
