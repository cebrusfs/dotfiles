# Neovim Plugin Review

Research date: 2026-06-24

Migration note for moving Neovim from vim-plug to built-in `vim.pack` without
changing editor behavior too aggressively. `config/nvim/init.lua` intentionally
keeps the old enabled plugin surface installed first. This file tracks plugins
that still need review; completed migrations keep their rationale beside the
new behavior in `config/nvim/init.lua`.

Stars and activity are approximate GitHub metadata checked on the research date.
Plugin follow-up data was refreshed on 2026-06-25.

## Current Policy

- Keep old enabled Neovim plugins installed via `vim.pack` until individually reviewed.
- Do not install new replacement candidates from this document without an explicit review.
- Prefer native Neovim behavior only when it preserves the workflow or the lost behavior is acceptable.
- After a plugin migration is complete, remove its evaluation entries from this
  document; keep the final rationale beside the active config instead.
- Keep original commented AI plugins as candidates only; they were not enabled before this migration.
- Adopt `mini.nvim` module-by-module. The Reddit review at
  <https://www.reddit.com/r/neovim/comments/1o6jjw0/my_review_of_minivim/>
  matches this policy: mini is strongest for small focused modules, while picker,
  file explorer, and Git replacements need workflow-specific testing.
- Let normal Neovim startup install missing `vim.pack` plugins. `./update` runs
  `:PackClean` as the `PlugClean` equivalent for plugins no longer declared by
  the current config; the command can also be run manually in a normal session.

## Mini.nvim Adoption Plan

`nvim-mini/mini.nvim` is installed as a module library. It has ~9.3k GitHub
stars and latest release `v0.18.0` on 2026-06-21. Enable modules only when they
replace an existing behavior cleanly.

| Mini module | Compared with | Recommendation |
|---|---|---|
| `mini.statusline` | `vim-airline`, `lualine.nvim`, native `statusline` | Candidate only after screenshots and statusline feature parity; airline remains familiar. |
| `mini.diff` | `gitsigns.nvim` | Defer. Reddit review liked number-column hunks, but gitsigns is proven and already configured. |
| `mini.files` | `NERDTree`, `oil.nvim`, netrw | Defer. Popup/file-explorer workflow differs from the current tree toggle. |
| `mini.pick` | `fzf-lua`, Telescope, snacks picker | Do not switch now. The Reddit review found fzf-lua faster/better for preview-heavy exploration, which matches the current `fd`/`rg` workflow. |
| `mini.git` | `vim-fugitive`, Lazygit | Do not switch now. It is buffer/session oriented; fugitive's `:Git` status view remains the current Git workflow. |
| `mini.indentscope` | `indent-blankline.nvim`, native `listchars` | Defer. It is scope-oriented rather than a straight indent guide replacement. |

## Equivalence Matrix

Use this table first when deciding whether an old plugin can be removed. "Equivalent"
means the replacement covers the behavior this config actually uses, not every
feature the old plugin exposes.

| Current plugin | Built-in replacement | mini.nvim replacement | Equivalence | Recommendation |
|---|---|---|---|---|
| `vim-airline/vim-airline` | Native `statusline` can reproduce output manually | `mini.statusline` | Not equivalent out of the box; both need visual/component parity work | Defer until screenshot parity. |
| `jacoborus/tender.vim` | None unless airline is removed | `mini.statusline` does not need airline themes | Equivalent only after airline replacement | Remove together with airline if statusline changes. |
| `preservim/nerdtree` | netrw is built-in but different; fzf-lua already covers file finding, not tree browsing | `mini.files` | Not equivalent to the current tree toggle workflow | Keep until file-tree workflow is redesigned. |
| `lukas-reineke/indent-blankline.nvim` | `listchars` can show indent-ish glyphs but not scope-aware guides | `mini.indentscope` | Not equivalent; mini shows current scope, not persistent indent guides | Keep. |
| `luochen1990/rainbow` | No built-in rainbow delimiter coloring | None in mini | No built-in/mini equivalent | Evaluate `rainbow-delimiters.nvim` if replacing. |
| `lewis6991/gitsigns.nvim` | Native signs plus `vim.diff()` are building blocks, not hunk UI | `mini.diff` | Mini partially equivalent for signs/hunks, but gitsigns has richer hunk actions | Keep unless intentionally simplifying Git hunk workflow. |
| `tpope/vim-fugitive` | Native `:terminal git` / shell commands are not an editor Git UI | `mini.git` | Not equivalent to fugitive's `:Git` status/edit workflow | Keep. |
| `ibhagwan/fzf-lua` | `vim.ui.select` is not a picker stack | `mini.pick` | Mini covers core picking, but current fd/rg preview workflow is stronger in fzf-lua | Keep. |
| `sickill/vim-pasta` | Native `]p`/`[p` and `:iput` adjust to the current line only | None | Not equivalent for block-context paste; `vim-pasta` opens an inferred destination line with `o`/`O` first | Keep unless accepting that narrower native behavior. |
| `tpope/vim-endwise` | No built-in auto `end` insertion | `mini.pairs` can pair delimiters, not language-aware Ruby/Lua `end` | Not equivalent | Keep unless adopting a snippet/autopairs workflow. |
| `vim-pandoc/vim-pandoc` | Built-in markdown does not provide Pandoc workflow commands | None | Not equivalent | Keep if Pandoc workflow is still used. |
| `vim-pandoc/vim-pandoc-syntax` | Built-in markdown/Tree-sitter markdown may cover highlighting, but Pandoc-specific syntax can differ | None | Partially equivalent for generic Markdown only | Keep while `vim-pandoc` remains. |
| `tomasiser/vim-code-dark` | Built-in `default` only | None | Not equivalent as a theme, but redundant if `vscode.nvim` is always active | Candidate to drop from Neovim after theme fallback decision. |
| `Mofiqul/vscode.nvim` | Built-in themes are available but visually different | `mini.base16`/`mini.hues` can create themes, not equivalent to VS Code theme | Not equivalent | Keep if this visual theme is desired. |
| `ShikChen/mojom.vim` | No built-in Mojom syntax confirmed | None | Not equivalent | Keep if Mojom files still matter. |
| GN runtime from `gn.googlesource.com` | No built-in GN syntax confirmed | None | Not equivalent | Keep if GN files still matter. |

## 2026-06-25 Batch Evaluation

| Area | Current data | Candidate data | Recommendation |
|---|---|---|---|
| Statusline | `vim-airline`: ~18.0k stars, latest release `v0.12` on 2026-05-02 | `lualine.nvim`: ~8.0k stars, pushed 2026-05-31; `mini.statusline` ships with active `mini.nvim` | No urgency. Airline is old-style Vimscript but still maintained; replace only with screenshot parity and component parity. |
| File explorer | `NERDTree`: ~20.1k stars, pushed 2025-09-26 | `oil.nvim`: ~6.7k stars, latest release `v2.16.0` on 2026-05-24; `nvim-tree.lua`: ~8.6k stars, latest release `v1.17.0` on 2026-04-07; `mini.files` ships with active `mini.nvim` | Keep for now. Choose `oil.nvim` only if buffer-style filesystem edits are desired; choose `nvim-tree.lua` if tree parity matters more. |
| Indent and delimiters | `indent-blankline.nvim`: ~5.0k stars, latest release `v3.9.1` on 2026-02-17; `rainbow`: ~1.8k stars, last release 2014, pushed 2024-07-27 | `rainbow-delimiters.nvim`: ~0.9k stars, pushed 2026-05-18 | Keep `indent-blankline.nvim`. Park `rainbow` for now; the lowest-maintenance replacement test is `rainbow-delimiters.nvim` on Neovim 0.12's built-in Tree-sitter parsers, without adding `nvim-treesitter`. |
| Pandoc Markdown | `vim-pandoc`: ~1.0k stars, pushed 2025-11-07; `vim-pandoc-syntax`: ~0.4k stars, pushed 2025-09-22 | Native Markdown / Tree-sitter Markdown, `render-markdown.nvim`, `markview.nvim` | Keep until Pandoc-specific commands and syntax behavior are checked. |
| Auto insertion and paste | `vim-endwise`: ~1.2k stars, pushed 2025-11-05; `vim-pasta`: ~0.3k stars, pushed 2023-08-12 | `nvim-autopairs`: ~4.1k stars, latest release `0.10.0` on 2025-09-26 | Keep `vim-endwise` unless adopting broader autopairs. `vim-pasta` is a removal candidate after paste indentation testing. |

## Rainbow Replacement Options

`rainbow-delimiters.nvim` still depends on Tree-sitter; Neovim 0.12 only removes the need for the old `nvim-treesitter` plugin in simple cases. Neovim's built-in parser set currently covers C, Lua, Markdown, Vimscript, and Vimdoc, so it fits a low-maintenance dotfiles-first trial but is not full language parity with the existing Vimscript `rainbow` config.

| Option | Path | Tradeoff |
|---|---|---|
| Keep current | Leave `luochen1990/rainbow` installed | Broad Vimscript behavior keeps the current HTML/TeX custom rules and disabled languages, but the plugin is old. |
| 0.12 low-maintenance trial | Add `HiPhish/rainbow-delimiters.nvim`, do not add `nvim-treesitter` | Uses Neovim 0.12 Tree-sitter runtime and built-in parsers only; limited coverage but low config cost. |
| Parser-managed trial | Add `rainbow-delimiters.nvim` plus a parser manager | Better language coverage, but introduces parser install/update policy and more moving parts. |
| Remove | Drop delimiter coloring entirely | Simplest config, but loses visual nesting aid. |

Current recommendation: leave `rainbow` alone until delimiter coloring is worth changing; if testing, start with the 0.12 low-maintenance trial.

## Paste Behavior Notes

Neovim's native `p`/`P` puts register text around the cursor. Native `]p`/`[p`
and `:iput` adjust pasted indentation to the current line, but they do not infer
the indentation of a new destination line inside a block. `vim-pasta` fills that
gap by opening a new line with `o`/`O`, letting filetype indent choose the
destination indentation, then pasting with `]p`.

Headless spot check on Neovim 0.12.3 with a Ruby-style block:

| Cursor / command | Result |
|---|---|
| Cursor on `if cond`, native `p` or `]p` | Pasted lines stay at column 0. |
| Cursor on `if cond`, `vim-pasta` `p` | Pasted lines land at inner block indent. |
| Cursor on `end`, native `[p` or `:iput!` | Pasted lines stay at column 0 before `end`. |
| Cursor on `end`, `vim-pasta` `P` | Pasted lines land at inner block indent before `end`. |
| Cursor already on an indented inner line, native `]p` | Equivalent enough; it aligns to that inner line. |

This config does not override `vim-pasta` defaults, so the plugin is disabled
for filetypes such as `python`, `markdown`, and `yaml`. That limits its value,
but also means removing it mostly affects languages where linewise block paste
under `if`/`end`-style scopes currently works better than native `]p`.

## Review Table

| Plugin | Current Neovim action | Role | Status / activity | Candidate / native path | Recommendation |
|---|---|---|---|---|---|
| `nvim-mini/mini.nvim` | Keep installed | Lua module library for small focused replacements | ~9.3k stars, latest release `v0.18.0` on 2026-06-21 | Enable modules selectively | Keep; active module rationale belongs in `config/nvim/init.lua`. |
| `tomasiser/vim-code-dark` | Keep installed | Vim-compatible colorscheme fallback | Small, stable theme | Keep only in Vim if Neovim always uses `vscode.nvim` | Later decide whether Neovim needs this fallback. |
| `Mofiqul/vscode.nvim` | Keep installed | Active Neovim colorscheme | ~1.0k stars, active in 2025 | `folke/tokyonight.nvim`, `loctvl842/monokai-pro.nvim` | Keep unless changing visual theme. |
| `vim-airline/vim-airline` | Keep installed | Statusline | ~18.0k stars, latest release `v0.12` on 2026-05-02 | `nvim-lualine/lualine.nvim` ~8.0k, `mini.statusline` from `mini.nvim` ~9.3k, native `statusline` | Keep for parity; review replacement only with screenshots and statusline feature parity. |
| `jacoborus/tender.vim` | Keep installed | Airline theme / colorscheme | Small, mature | Match replacement statusline theme manually | Keep while airline is kept. |
| `preservim/vim-indent-guides` | Keep installed | Vim indent guides | Canonical repo for old `nathanaelkane` URL, mature | For Neovim, `lukas-reineke/indent-blankline.nvim` is already installed | Keep for Vim; consider removing from Neovim after confirming it is unused there. |
| `lukas-reineke/indent-blankline.nvim` | Keep installed | Neovim indent guides | ~5.0k stars, latest release `v3.9.1` on 2026-02-17 | `mini.indentscope` from `mini.nvim`, or native `listchars` only | Keep for parity; native `listchars` is not a full scope guide. |
| `luochen1990/rainbow` | Keep installed | Delimiter coloring | ~1.8k stars, latest release `v3.3.1` in 2014, pushed 2024-07-27 | `HiPhish/rainbow-delimiters.nvim` ~0.9k, pushed 2026-05-18 | Park for now. If tested, prefer the 0.12 low-maintenance path first: `rainbow-delimiters.nvim` with built-in parsers only. |
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
| `sickill/vim-pasta` | Keep installed | Paste indentation adjustment | Redirects to `ku1ik/vim-pasta`, ~0.3k stars, pushed 2023-08-12 | Native `]p`/`[p` covers only current-line indent; `smart-paste.nvim` is newer but small | Not natively replaced. Keep unless the block-context paste behavior is no longer worth a plugin. |
| `preservim/nerdtree` | Keep installed | File tree | ~20.1k stars, pushed 2025-09-26 | `stevearc/oil.nvim` ~6.7k, `nvim-tree.lua` ~8.6k, netrw + fzf-lua | Keep for parity; review replacement as a workflow decision, not a quick swap. |
| `tpope/vim-endwise` | Keep installed | Auto `end` insertion | ~1.2k stars, pushed 2025-11-05 | `windwp/nvim-autopairs` ~4.1k or language-specific snippets | Keep; small and low risk. |
| `vim-pandoc/vim-pandoc` | Keep installed | Pandoc markdown workflow | ~1.0k stars, pushed 2025-11-07 | Native markdown, `render-markdown.nvim`, `markview.nvim` | Keep until Pandoc-specific behavior is checked. |
| `vim-pandoc/vim-pandoc-syntax` | Keep installed | Pandoc syntax | ~0.4k stars, pushed 2025-09-22 | Native markdown / Tree-sitter markdown | Keep while `vim-pandoc` is kept. |
| `ShikChen/mojom.vim` | Keep installed | Mojom syntax | Niche, low activity | Local syntax file if needed | Keep if mojom files still matter. |
| GN runtime from `gn.googlesource.com` | Keep installed | BUILD.gn syntax | Upstream GN repo | Local syntax copy if plugin manager friction is high | Keep if GN files still matter. |
| `github/copilot.vim` | Not installed; old config had it commented | AI completion candidate | ~11.6k stars | Native LSP inline completion path or vendor plugin | Keep commented unless explicitly adopting AI completion. |
| `supermaven-inc/supermaven-nvim` | Not installed; old config had it commented | AI completion candidate | ~1.4k stars, lower recent activity | Copilot or no AI plugin | Keep commented unless explicitly adopting AI completion. |

## Suggested Review Order

1. Next low-risk replacement test: `rainbow`.
2. Removal candidate that needs paste tests: `vim-pasta`.
3. UI workflow decisions: `vim-airline`, `NERDTree`, `indent-blankline.nvim`.
4. Programming stack: `nvim-cmp` family, `mason*`, `nvim-lspconfig`.
5. Niche filetypes and prose tools: `vim-pandoc*`, `mojom.vim`, GN runtime.

## Verification Notes

For any removal or replacement, run at least:

```sh
env XDG_CONFIG_HOME="$PWD/config" \
  XDG_DATA_HOME="$TMPDIR/nvim-data" \
  XDG_STATE_HOME="$TMPDIR/nvim-state" \
  XDG_CACHE_HOME="$TMPDIR/nvim-cache" \
  nvim --headless -n --cmd 'set noloadplugins' --cmd 'set shada=' +qa
```

Then test interactively with the actual plugin installed, because
`set noloadplugins` only proves the config has a clean no-plugin fallback path.

For focused headless probes that use `--clean` instead of the repo config, keep
the isolated `XDG_STATE_HOME` and `XDG_CACHE_HOME` values and still pass `-n`
plus `--cmd 'set shada='`. Without a writable state directory, Neovim can fall
back to writing `nvim.log` in the current working directory.
