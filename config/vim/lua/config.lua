-- setup colorscheme {
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
require("ibl").setup()
-- }

require("supermaven-nvim").setup({})
