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

-- fzf-lua {
require('fzf-lua').setup({
  defaults = {
    file_ignore_patterns = { "node_modules", ".git", "__pycache__" }
  },
  -- Use fzf's native ripgrep integration for speed
  files = {
    fd_opts = "--color=never --type f --hidden --follow --exclude .git",
  },
  grep = {
    rg_opts = "--color=never --hidden --follow",
  },
})

local fzf = require('fzf-lua')

-- Keybindings for file/content search
-- Find files in project
vim.keymap.set('n', '<leader>fo', fzf.files, { desc = "Find files" })

-- Live grep in project
vim.keymap.set('n', '<leader>r', fzf.live_grep, { desc = "Live grep in project" })
vim.keymap.set('n', '<leader><space>r', function()
  fzf.live_grep({ search = vim.fn.expand('<cword>') })
end, { desc = "Live grep current word in project" })

-- Search in current buffer
vim.keymap.set('n', '<leader>/', fzf.blines, { desc = "Search in current buffer" })

-- Search in all open buffers
vim.keymap.set('n', '<leader>.', fzf.buffers, { desc = "Search in open buffers" })

-- Help tags
vim.keymap.set('n', '<leader>fh', fzf.help_tags, { desc = "Help tags" })

-- LSP keybindings (using Neovim's default LSP)
-- Note: gd, gr, gI, etc. are Neovim's built-in LSP keybindings
-- If you want to use fzf-lua for LSP, uncomment below:
-- vim.keymap.set('n', 'gd', fzf.lsp_definitions, { desc = "Go to definition" })
-- vim.keymap.set('n', 'gr', fzf.lsp_references, { desc = "Find references" })
-- vim.keymap.set('n', 'gI', fzf.lsp_implementations, { desc = "Go to implementation" })
-- }

