if vim.g.vscode == nil then
    vim.g.loaded_netrw = 1
    vim.g.loaded_netrwPlugin = 1
    -- vim.keymap.set("n", "<A-b>", ':NvimTreeOpen<CR>', {})

    -- set termguicolors to enable highlight groups
    vim.opt.termguicolors = true

    -- empty setup using defaults
    require("nvim-tree").setup()

    -- OR setup with some options
    require("nvim-tree").setup({
        sort_by = "case_sensitive",
        view = {
            width = 30,
        },
        renderer = {
            group_empty = true,
        },
        filters = {
            dotfiles = true,
        },
    })
end
