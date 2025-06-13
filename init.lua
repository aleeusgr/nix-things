-- Bootstrap lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Setup plugins using lazy.nvim
require("lazy").setup({
  -- Add plugins here:
  { "neovim/nvim-lspconfig" },        -- LSP support
  { "nvim-treesitter/nvim-treesitter", build = ":TSUpdate" }, -- better syntax highlighting
  { "nvim-lua/plenary.nvim" },        -- Useful Lua functions
  { "LnL7/vim-nix" },                 -- Nix syntax
  { "nvim-telescope/telescope.nvim" },-- Fuzzy finder
  { "nvim-lualine/lualine.nvim" },    -- Status line
  -- Add more as needed
})

-- Your settings
vim.o.syntax = "on"
vim.o.relativenumber = true
vim.o.number = true
vim.o.laststatus = 2
vim.o.hidden = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.incsearch = true
vim.keymap.set('n', 'Q', '<Nop>', {noremap = true})
vim.o.errorbells = false
vim.o.visualbell = true

-- Example: treesitter config
require('nvim-treesitter.configs').setup {
  highlight = { enable = true }
}

-- Example: lualine config
require('lualine').setup {}

-- Example: telescope config
require('telescope').setup {}

-- Setup Haskell LSP using nvim-lspconfig
require('lspconfig').hls.setup{
  settings = {
    haskell = {
      formattingProvider = "ormolu", -- or any you prefer
    }
  }
}

-- LSP keymaps
vim.keymap.set('n', 'gd', vim.lsp.buf.definition, { desc = "Go to definition" })
vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = "Hover documentation" })
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, { desc = "Rename symbol" })
vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, { desc = "Code action" })

require('lspconfig').nil_ls.setup{
  settings = {
    ['nil'] = {
      formatting = {
        command = { "nixpkgs-fmt" }
      }
    }
  }
}

-- require('llm').setup {
--   model = "codegemma",
--   backend = "ollama",
--   url = "http://localhost:11434/api/generate",
--   request_body = {
--     options = {
--       temperature = 0,
--       top_p = 0.9,
--     }
--   },
--   tokens_to_clear = { "<EOT>" },
--   fim = {
--     enabled = true,
--     prefix = "<PRE> ",
--     middle = " <MID>",
--     suffix = " <SUF>",
--   },
--   accept_keymap = "<M-j>",
--   dismiss_keymap = "<M-h>",
--   context_window = 1024,
--   lsp = {
--     version = "0.5.2",
--   },
--   enable_suggestions_on_startup = false,
-- }
