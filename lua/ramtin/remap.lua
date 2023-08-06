vim.g.mapleader = " "

-- Sample of calling VS Code functionalities
vim.keymap.set("n", "z1", ":<C-u>call VSCodeNotify('editor.action.triggerSuggest')<CR>")

-- Insert Mode Navigation
vim.keymap.set("i", "<C-f>", '<right>')
vim.keymap.set("i", "<C-b>", '<left>')
vim.keymap.set("i", "<C-p>", '<up>')
vim.keymap.set("i", "<C-n>", '<down>')

-- Remapping Enter to add new line
vim.api.nvim_set_keymap('n', '<CR>', 'o<Esc>', { noremap = true, silent = true })

-- Remapping Backspace to remove a line
vim.api.nvim_set_keymap('n', '<BS>', 'ddk', { noremap = true, silent = true })

-- visual multi

