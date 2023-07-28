vim.g.mapleader = " "

-- Sample of calling VS Code functionalities
vim.keymap.set("n", "z1", ":<C-u>call VSCodeNotify('editor.action.triggerSuggest')<CR>")

-- Insert Mode Navigation
vim.keymap.set("i", "<C-f>", '<right>')
vim.keymap.set("i", "<C-b>", '<left>')
vim.keymap.set("i", "<C-p>", '<up>')
vim.keymap.set("i", "<C-n>", '<down>')

-- visual multi

