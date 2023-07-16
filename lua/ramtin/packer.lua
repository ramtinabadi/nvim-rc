-- This file can be loaded by calling `lua require('plugins')` from your init.vim

-- Only required if you have packer configured as `opt`
vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function(use)
    -- Packer can manage itself
    use 'wbthomason/packer.nvim'

    -- Telescope
    use {
      'nvim-telescope/telescope.nvim', tag = '0.1.2',
      requires = { {'nvim-lua/plenary.nvim'} }
    }

    -- Rose Pine Color Scheme
    use({ 
        'rose-pine/neovim', 
        as = 'rose-pine',
        config = function()
            vim.cmd('colorscheme rose-pine')
        end
    })

    -- Tree Sitter
    use('nvim-treesitter/nvim-treesitter', { run = ':TSUpdate' })

    -- Undo tree
    use('mbbill/undotree')

    -- Fugitive
    use('tpope/vim-fugitive')

    -- LSP Zero
    use {
        'VonHeikemen/lsp-zero.nvim',
        branch = 'v2.x',
        requires = {
            -- LSP Support
            {'neovim/nvim-lspconfig'},             -- Required
            {                                      -- Optional
            'williamboman/mason.nvim',
            run = function()
                pcall(vim.cmd, 'MasonUpdate')
            end,
        },
        {'williamboman/mason-lspconfig.nvim'}, -- Optional

        -- Autocompletion
        {'hrsh7th/nvim-cmp'},     -- Required
        {'hrsh7th/cmp-nvim-lsp'}, -- Required
        {'L3MON4D3/LuaSnip'},     -- Required
    }
}

end)
