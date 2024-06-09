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
--   model = "codegemma:7b",
--   url = "http://localhost:11434", -- llm-ls uses "/api/generate"
--   -- cf https://github.com/ollama/ollama/blob/main/docs/api.md#parameters
--   request_body = {
--     -- Modelfile options for the model you use
--     options = {
--       temperature = 0.2,
--       top_p = 0.95,
--     }
--   }
-- }
