-- vim: ts=4 sts=4 sw=4 et

local function source_first_readable(candidates)
    for _, file in ipairs(candidates) do
        if vim.fn.filereadable(file) == 1 then
            vim.cmd.source(vim.fn.fnameescape(file))
            return
        end
    end
end

source_first_readable({
    vim.fn.expand("~/.vim/common.vim"),
    vim.fn.fnamemodify(vim.fn.stdpath("config") .. "/../vim/common.vim", ":p"),
})

vim.o.laststatus = 2
vim.opt.completeopt:append({ "menuone", "noselect", "popup" })

local function gh(repo)
    return { src = "https://github.com/" .. repo }
end

-- Keep the old Neovim plugin surface installed first. Review
-- docs/nvim-plugin-review.md before removing or replacing each dependency.
vim.cmd([=[
let g:airline_theme = 'tender'
let g:airline_powerline_fonts = 1

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

let g:NERDCreateDefaultMappings = 0
let g:NERDSpaceDelims = 1
let g:NERDCompactSexyComs = 1
let g:NERDCommentEmptyLines = 1
let g:NERDToggleCheckAllLines = 1
let g:NERDCustomDelimiters = {
    \'armasm': {'left': '@'},
\}

let g:pandoc#syntax#conceal#urls = 1
let g:grammarous#default_comments_only_filetypes = {
    \ '*' : 1,
    \ 'help' : 0,
    \ 'markdown' : 0,
    \ }
]=])

local pack_specs = {
    gh("tomasiser/vim-code-dark"),
    gh("Mofiqul/vscode.nvim"),
    gh("vim-airline/vim-airline"),
    gh("jacoborus/tender.vim"),
    gh("preservim/vim-indent-guides"),
    gh("lukas-reineke/indent-blankline.nvim"),
    gh("inkarkat/vim-ingo-library"),
    gh("inkarkat/vim-ShowTrailingWhitespace"),
    gh("luochen1990/rainbow"),
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
    gh("tpope/vim-fugitive"),
    gh("junegunn/vim-easy-align"),
    gh("sickill/vim-pasta"),
    gh("preservim/nerdtree"),
    gh("preservim/nerdcommenter"),
    gh("tpope/vim-endwise"),
    gh("vim-pandoc/vim-pandoc"),
    gh("vim-pandoc/vim-pandoc-syntax"),
    gh("ShikChen/mojom.vim"),
    gh("coquelicot/local-vimrc"),
    gh("easymotion/vim-easymotion"),
    gh("rhysd/vim-grammarous"),
    gh("ShikChen/osc52.vim"),
    { src = "https://gn.googlesource.com/gn", name = "gn" },
}

if vim.pack and vim.env.NVIM_SKIP_PACK ~= "1" then
    vim.pack.add(pack_specs, { confirm = false, load = true })
elseif not vim.pack then
    vim.notify("vim.pack requires Neovim 0.12+", vim.log.levels.WARN)
end

vim.opt.runtimepath:append(vim.fn.stdpath("data") .. "/site/pack/core/opt/gn/misc/vim")

vim.keymap.set("n", "<S-Tab>", "<cmd>NERDTreeToggle<CR>", { desc = "Toggle NERDTree" })
vim.keymap.set("n", "<Bslash>", "<Plug>NERDCommenterToggle", { remap = true, desc = "Toggle comment" })
vim.keymap.set("x", "<Bslash>", "<Plug>NERDCommenterToggle", { remap = true, desc = "Toggle comment" })
vim.keymap.set("x", "Y", [[y:call SendViaOSC52(getreg('"'))<CR>]], { desc = "Yank via OSC52" })

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

vim.diagnostic.config({
    virtual_lines = {
        current_line = true,
    },
})

local capabilities = vim.lsp.protocol.make_client_capabilities()

local ok_cmp_nvim_lsp, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if ok_cmp_nvim_lsp then
    capabilities = cmp_nvim_lsp.default_capabilities(capabilities)
end

vim.lsp.config("*", {
    capabilities = capabilities,
})

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

local ok_gitsigns, gitsigns = pcall(require, "gitsigns")
if ok_gitsigns then
    gitsigns.setup()
end

local ok_ibl, ibl = pcall(require, "ibl")
if ok_ibl then
    vim.opt.list = true
    vim.opt.listchars:append({ multispace = "." })
    vim.opt.listchars:remove("space")
    vim.opt.listchars:remove("trail")
    ibl.setup()
end

vim.keymap.set("n", "<Leader>g", "<Nop>", { desc = "Git prefix" })
vim.keymap.set("n", "<Leader>gs", "<cmd>Git<CR>", { desc = "Git status" })
vim.keymap.set("n", "<Leader>gd", "<cmd>Gdiffsplit<CR>", { desc = "Git diff" })
vim.keymap.set("n", "<Leader>gb", "<cmd>Git blame<CR>", { desc = "Git blame" })
vim.keymap.set("n", "<Leader>gm", "<cmd>Git mergetool<CR>", { desc = "Git mergetool" })

vim.keymap.set("x", "<Leader>-", "<Plug>(EasyAlign)", { remap = true, desc = "EasyAlign" })
vim.keymap.set("n", "<Leader>-", "<Plug>(EasyAlign)", { remap = true, desc = "EasyAlign" })

local ok_fzf, fzf = pcall(require, "fzf-lua")
if ok_fzf then
    fzf.setup({
        defaults = {
            file_ignore_patterns = { "node_modules", ".git", "__pycache__" },
        },
        files = {
            fd_opts = "--color=never --type f --hidden --follow --exclude .git",
        },
        grep = {
            rg_opts = "--color=never --hidden --follow",
        },
    })

    vim.keymap.set("n", "<Leader>fo", fzf.files, { desc = "Find files" })
    vim.keymap.set("n", "<Leader>r", fzf.live_grep, { desc = "Live grep in project" })
    vim.keymap.set("n", "<Leader><Space>r", function()
        fzf.live_grep({ search = vim.fn.expand("<cword>") })
    end, { desc = "Live grep current word in project" })
    vim.keymap.set("n", "<Leader>/", fzf.blines, { desc = "Search in current buffer" })
    vim.keymap.set("n", "<Leader>.", fzf.buffers, { desc = "Search in open buffers" })
    vim.keymap.set("n", "<Leader>fh", fzf.help_tags, { desc = "Help tags" })
end
