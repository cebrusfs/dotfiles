# Neovim Plugin Review

Research date: 2026-06-24

Migration note for moving Neovim from vim-plug to built-in `vim.pack` without
changing editor behavior too aggressively. `config/nvim/init.lua` intentionally
keeps the old enabled plugin surface installed first. Use this table to review
one dependency at a time before removing or replacing it.

Stars and activity are approximate GitHub metadata checked on the research date.

## Current Policy

- Keep old enabled Neovim plugins installed via `vim.pack` until individually reviewed.
- Do not install new replacement candidates from this document without an explicit review.
- Prefer native Neovim behavior only when it preserves the workflow or the lost behavior is acceptable.
- Keep original commented AI plugins as candidates only; they were not enabled before this migration.

## Review Table

| Plugin | Current Neovim action | Role | Status / activity | Candidate / native path | Recommendation |
|---|---|---|---|---|---|
| `tomasiser/vim-code-dark` | Keep installed | Vim-compatible colorscheme fallback | Small, stable theme | Keep only in Vim if Neovim always uses `vscode.nvim` | Later decide whether Neovim needs this fallback. |
| `Mofiqul/vscode.nvim` | Keep installed | Active Neovim colorscheme | ~1.0k stars, active in 2025 | `folke/tokyonight.nvim`, `loctvl842/monokai-pro.nvim` | Keep unless changing visual theme. |
| `vim-airline/vim-airline` | Keep installed | Statusline | ~21k stars, mature | `nvim-lualine/lualine.nvim` ~8.0k, `mini.statusline` from `mini.nvim` ~9.3k, native `statusline` | Keep for parity; review replacement only with screenshots and statusline feature parity. |
| `jacoborus/tender.vim` | Keep installed | Airline theme / colorscheme | Small, mature | Match replacement statusline theme manually | Keep while airline is kept. |
| `preservim/vim-indent-guides` | Keep installed | Vim indent guides | Canonical repo for old `nathanaelkane` URL, mature | For Neovim, `lukas-reineke/indent-blankline.nvim` is already installed | Keep for Vim; consider removing from Neovim after confirming it is unused there. |
| `lukas-reineke/indent-blankline.nvim` | Keep installed | Neovim indent guides | Active enough, Neovim-specific | `mini.indentscope` from `mini.nvim`, or native `listchars` only | Keep for parity; native `listchars` is not a full scope guide. |
| `inkarkat/vim-ingo-library` | Keep installed | Dependency for trailing whitespace plugin | Small, mature | Remove if `vim-ShowTrailingWhitespace` is removed | Keep only because dependent plugin needs it. |
| `inkarkat/vim-ShowTrailingWhitespace` | Keep installed | Trailing whitespace highlight | Small, low activity | Native `matchadd()` / autocmd | Keep for parity; native replacement is simple but changes implementation. |
| `luochen1990/rainbow` | Keep installed | Delimiter coloring | ~1.8k stars, mature | `HiPhish/rainbow-delimiters.nvim` ~0.9k | Keep for parity; review Tree-sitter based replacement separately. |
| `neovim/nvim-lspconfig` | Keep installed | LSP server config database | ~13.8k stars, active | Native `vim.lsp.config` plus local configs | Keep. The deprecated part is old `require('lspconfig').setup`, not the config database. |
| `mason-org/mason.nvim` | Keep installed | LSP/tool installer | ~10.3k stars, active | System package managers / mise / manual installs | Keep unless tool installation moves outside Neovim. |
| `mason-org/mason-lspconfig.nvim` | Keep installed | Mason to lspconfig bridge | ~3.9k stars, active | Manual `vim.lsp.enable()` list | Keep for now; later review whether auto-enable is desired. |
| `hrsh7th/nvim-cmp` | Keep installed | Completion UI/engine | ~9.5k stars, active enough | Native `vim.lsp.completion`, `saghen/blink.cmp` ~6.4k | Keep for parity. Native completion loses current buffer/path/cmdline polish. |
| `hrsh7th/cmp-nvim-lsp` | Keep installed | LSP source for nvim-cmp | Companion plugin | Native LSP completion or blink source | Keep while `nvim-cmp` is kept. |
| `hrsh7th/cmp-buffer` | Keep installed | Buffer words source | Companion plugin | Native insert completion | Keep while `nvim-cmp` is kept. |
| `hrsh7th/cmp-path` | Keep installed | Path source | Companion plugin | Native file completion | Keep while `nvim-cmp` is kept. |
| `hrsh7th/cmp-cmdline` | Keep installed | Cmdline completion source | Companion plugin | Native cmdline completion | Keep while `nvim-cmp` is kept. |
| `ibhagwan/fzf-lua` | Keep installed | Fuzzy files/grep/buffers/help | ~4.3k stars, active | `folke/snacks.nvim` picker, Telescope | Keep; actively maintained and already replaces several older navigation plugins. |
| `lewis6991/gitsigns.nvim` | Keep installed | Git signs/hunks | ~6.9k stars, active | Native signs plus fugitive, or mini.diff | Keep. |
| `tpope/vim-fugitive` | Keep installed | Git command workflow | ~21.7k stars, mature | Neogit, Lazygit, native git commands | Keep; small and proven. |
| `junegunn/vim-easy-align` | Keep installed | Alignment operator | ~4.2k stars, mature | mini.align or built-in formatting per filetype | Keep unless an alignment workflow replacement is chosen. |
| `sickill/vim-pasta` | Keep installed | Paste indentation adjustment | Old repo redirects to current owner, low activity | Native paste/indent behavior | Keep for parity; good candidate to remove after paste workflow testing. |
| `preservim/nerdtree` | Keep installed | File tree | ~20k stars, mature | `stevearc/oil.nvim` ~6.7k, `nvim-tree.lua` ~8.6k, netrw + fzf-lua | Keep for parity; review replacement as a workflow decision, not a quick swap. |
| `preservim/nerdcommenter` | Keep installed | Comment toggling | ~5.0k stars, mature | Native `gc/gcc`, `numToStr/Comment.nvim` ~4.7k | Keep for parity; native comment is viable if custom delimiter behavior is enough. |
| `tpope/vim-endwise` | Keep installed | Auto `end` insertion | ~1.2k stars, mature | `windwp/nvim-autopairs` ~4.1k or language-specific snippets | Keep; small and low risk. |
| `vim-pandoc/vim-pandoc` | Keep installed | Pandoc markdown workflow | ~1.0k stars, mature | Native markdown, `render-markdown.nvim`, `markview.nvim` | Keep until Pandoc-specific behavior is checked. |
| `vim-pandoc/vim-pandoc-syntax` | Keep installed | Pandoc syntax | ~0.4k stars, mature | Native markdown / Tree-sitter markdown | Keep while `vim-pandoc` is kept. |
| `ShikChen/mojom.vim` | Keep installed | Mojom syntax | Niche, low activity | Local syntax file if needed | Keep if mojom files still matter. |
| GN runtime from `gn.googlesource.com` | Keep installed | BUILD.gn syntax | Upstream GN repo | Local syntax copy if plugin manager friction is high | Keep if GN files still matter. |
| `coquelicot/local-vimrc` | Keep installed | Project-local vimrc | Low activity | Native Neovim `exrc` + trust | Keep for parity; native `exrc` is a security/UX migration that needs deliberate review. |
| `easymotion/vim-easymotion` | Keep installed | Jump navigation | Mature, older | `folke/flash.nvim` ~4.1k, `ggandor/leap.nvim` ~5.0k | Keep for parity; replacement changes muscle memory. |
| `rhysd/vim-grammarous` | Keep installed | Grammar checking | ~1.1k stars, low activity | LSP/external prose checker | Keep for parity; strong candidate to remove if unused. |
| `ShikChen/osc52.vim` | Keep installed | Remote clipboard over OSC52 | Niche, low activity | Native Neovim OSC52 provider | Keep for parity; native provider is likely enough but should be tested over SSH/tmux. |
| `github/copilot.vim` | Not installed; old config had it commented | AI completion candidate | ~11.6k stars | Native LSP inline completion path or vendor plugin | Keep commented unless explicitly adopting AI completion. |
| `supermaven-inc/supermaven-nvim` | Not installed; old config had it commented | AI completion candidate | ~1.4k stars, lower recent activity | Copilot or no AI plugin | Keep commented unless explicitly adopting AI completion. |

## Suggested Review Order

1. Low-risk implementation swaps: `osc52.vim`, `vim-ShowTrailingWhitespace`, `local-vimrc`.
2. UI workflow decisions: `vim-airline`, `NERDTree`, `indent-blankline.nvim`, `rainbow`.
3. Editing muscle memory: `nerdcommenter`, `easymotion`, `vim-easy-align`, `vim-pasta`.
4. Programming stack: `nvim-cmp` family, `mason*`, `nvim-lspconfig`.
5. Niche filetypes and prose tools: `vim-pandoc*`, `mojom.vim`, GN runtime, `vim-grammarous`.

## Verification Notes

For any removal or replacement, run at least:

```sh
env XDG_CONFIG_HOME="$PWD/config" \
  XDG_DATA_HOME="$TMPDIR/nvim-data" \
  XDG_STATE_HOME="$TMPDIR/nvim-state" \
  XDG_CACHE_HOME="$TMPDIR/nvim-cache" \
  NVIM_SKIP_PACK=1 \
  nvim --headless +qa
```

Then test interactively with the actual plugin installed, because `NVIM_SKIP_PACK`
only proves the config has a clean no-plugin fallback path.
