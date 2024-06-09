-- Comments in Lua start with a `--`.

-- Turn on syntax highlighting.
vim.o.syntax = "on"

-- Show line numbers.
vim.o.relativenumber = true
vim.o.number = true

-- Always show the status line at the bottom, even if you only have one window open.
vim.o.laststatus = 2

-- Allow hiding buffers with unsaved changes.
vim.o.hidden = true

-- Make search case-insensitive when all characters are lowercase.
vim.o.ignorecase = true
vim.o.smartcase = true

-- Enable searching as you type, rather than waiting till you press enter.
vim.o.incsearch = true

-- Unbind some useless/annoying default key bindings.
vim.keymap.set('n', 'Q', '<Nop>', {noremap = true})

-- Disable audible bell because it's annoying.
vim.o.errorbells = false
vim.o.visualbell = true

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
