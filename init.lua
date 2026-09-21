if vim.g.vscode then
    vim.opt.ignorecase = true

    -- Key mappings for folding and unfolding
    vim.api.nvim_set_keymap('n', 'zM', ":call VSCodeNotify('editor.foldAll')<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'zR', ":call VSCodeNotify('editor.unfoldAll')<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'zc', ":call VSCodeNotify('editor.fold')<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'zC', ":call VSCodeNotify('editor.foldRecursively')<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'zo', ":call VSCodeNotify('editor.unfold')<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'zO', ":call VSCodeNotify('editor.unfoldRecursively')<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', 'za', ":call VSCodeNotify('editor.toggleFold')<CR>", { noremap = true, silent = true })

    require("vscode_integration")
else
    require("ramtin")
end
