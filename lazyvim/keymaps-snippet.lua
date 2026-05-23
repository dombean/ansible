-- >>> custom: auto-centring cursor (managed by install script)
-- Keep cursor centred when navigating
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "G", "Gzz")
vim.keymap.set("n", "*", "*zz")
vim.keymap.set("n", "#", "#zz")
-- <<< custom: auto-centring cursor
