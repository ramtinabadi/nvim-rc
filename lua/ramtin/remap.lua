vim.g.mapleader = " "

-- Define a function to save the file and exit insert mode
local function save_and_exit()
  vim.cmd('stopinsert') -- Exit insert mode
  vim.cmd('write') -- Save the file
end

-- Exit insert mode and save file
vim.api.nvim_set_keymap('i', '<C-]>', '<Cmd>lua save_and_exit()<CR>', { noremap = true, silent = true })

-- Sample of calling VS Code functionalities
vim.keymap.set("n", "z1", ":<C-u>call VSCodeNotify('editor.action.triggerSuggest')<CR>")


-- visual multi

