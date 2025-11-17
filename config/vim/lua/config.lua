-- vim: ts=4 ts=4 sts=4
-- vim: foldmarker={,} foldlevel=0 foldmethod=marker:

-- Colorscheme {
local c = require('vscode.colors').get_colors()
require('vscode').setup({
    -- Alternatively set style in setup
    -- style = 'light'

    -- Enable transparent background
    transparent = true,

    -- Enable italic comment
    italic_comments = true,

    -- Underline `@markup.link.*` variants
    underline_links = true,

    -- Disable nvim-tree background color
    disable_nvimtree_bg = true,
})

-- require('vscode').load()
vim.cmd.colorscheme "vscode"
-- }

-- lukas-reineke/indent-blankline {

-- Show space when there are multispace
vim.opt.list = true
vim.opt.listchars:append({ multispace = "·" })
vim.opt.listchars:remove('space')
vim.opt.listchars:remove('trail') -- We don't need this as we have another plugin to show trail space

require("ibl").setup()
-- }

-- Gitsigns {
require('gitsigns').setup()
-- }

-- LSP, Autocompletion and other programming enhancements {

-- Setup Mason and lspconfig.
require("mason").setup()
require("mason-lspconfig").setup({
  -- A list of servers to automatically install if they're not already installed
  ensure_installed = {
    -- C/C++
    'clangd',
    -- Python
    'pyright',
    -- Ruby
    'solargraph',
    -- Typescript
    'ts_ls',
    -- Rust
    'rust_analyzer',
    -- Bash
    'bashls',
    -- JSON
    'jsonls',
    -- YAML
    'yamlls',
    -- Toml
    'taplo',
    -- Lua (for neovim config)
    'stylua',
  }
})

-- Set up nvim-cmp.
local cmp = require'cmp'

cmp.setup({
  snippet = {
    -- REQUIRED - you must specify a snippet engine
    expand = function(args)
      -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
      -- require('luasnip').lsp_expand(args.body) -- For `luasnip` users.
      -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
      -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
      vim.snippet.expand(args.body) -- For native neovim snippets (Neovim v0.10+)

      -- For `mini.snippets` users:
      -- local insert = MiniSnippets.config.expand.insert or MiniSnippets.default_insert
      -- insert({ body = args.body }) -- Insert at cursor
      -- cmp.resubscribe({ "TextChangedI", "TextChangedP" })
      -- require("cmp.config").set_onetime({ sources = {} })
    end,
  },
  window = {
    -- completion = cmp.config.window.bordered(),
    -- documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
    -- Primary sources
    { name = 'nvim_lsp' },
    {
      name = 'path',
      option = {
        -- Specify if completed directory names should include a trailing slash. Enabling this option makes this source behave like Vim's built-in path completion.
        trailing_slash = true,
      },
    }
    -- { name = 'vsnip' }, -- For vsnip users.
    -- { name = 'luasnip' }, -- For luasnip users.
    -- { name = 'ultisnips' }, -- For ultisnips users.
    -- { name = 'snippy' }, -- For snippy users.
  }, {
    -- Secondary sources

    -- From current buffer
    { name = 'buffer' },
  })
})

-- To use git you need to install the plugin petertriho/cmp-git and uncomment lines below
-- Set configuration for specific filetype.
--[[ cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources({
    { name = 'git' },
  }, {
    { name = 'buffer' },
  })
})
require("cmp_git").setup() ]]--

-- Use buffer source for `/` and `?` (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

-- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})

-- Set up lspconfig.
local capabilities = require('cmp_nvim_lsp').default_capabilities()
-- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
-- require('lspconfig')['<YOUR_LSP_SERVER>'].setup {
--  capabilities = capabilities
-- }

-- Remap old fzf keybindings to telescope
--vim.keymap.set('n', '<leader>fo', '<cmd>Telescope find_files<cr>', { desc = "Find files" })
--vim.keymap.set('n', '<leader>fr', '<cmd>Telescope live_grep<cr>', { desc = "Live grep" })
--vim.keymap.set('n', '<leader>fb', '<cmd>Telescope buffers<cr>', { desc = "Find buffers" })
--vim.keymap.set('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', { desc = "Help tags" })

-- General key mappings for LSP features
-- NOTE: These mappings will only be active in buffers where an LSP client is attached.
-- vim.api.nvim_create_autocmd('LspAttach', {
  -- group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  -- callback = function(ev)
    -- -- Enable completion on typing
    -- vim.api.nvim_buf_set_option(ev.buf, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
-- 
    -- -- Buffer local mappings.
    -- -- See `:help vim.lsp.*` for documentation on any of the below functions
    -- local opts = { buffer = ev.buf }
    -- -- GoTo code navigation
    -- vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    -- vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    -- vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    -- vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    -- vim.keymap.set('n', 'gt', vim.lsp.buf.type_definition, opts)
-- 
    -- -- Hover documentation
    -- vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
-- 
    -- -- Signature help
    -- vim.keymap.set('i', '<C-k>', vim.lsp.buf.signature_help, opts)
-- 
    -- -- Workspace symbols and renaming
    -- vim.keymap.set('n', '<leader>ws', vim.lsp.buf.workspace_symbol, opts)
    -- vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
-- 
    -- -- Code actions
    -- vim.keymap.set({ 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, opts)
-- 
    -- -- Diagnostics
    -- vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
    -- vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
    -- vim.keymap.set('n', '<leader>dl', vim.diagnostic.open_float, opts)
    -- vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, opts)
-- 
    -- -- Formatting
    -- -- Note: We use conform.nvim for formatting, but this is a fallback
    -- vim.keymap.set({'n', 'v'}, '<leader>=', function()
      -- vim.lsp.buf.format({ async = true })
    -- end, opts)
-- 
    -- -- Highlight symbol on cursor hold
    -- vim.api.nvim_create_autocmd('CursorHold', {
      -- buffer = ev.buf,
      -- callback = vim.lsp.buf.document_highlight,
    -- })
    -- vim.api.nvim_create_autocmd('CursorMoved', {
      -- buffer = ev.buf,
      -- callback = vim.lsp.buf.clear_references,
    -- })
  -- end,
-- })
-- }
