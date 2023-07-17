if vim.g.vscode == nil then
    vim.keymap.set("n", "<leader>gs", vim.cmd.Git)
end
