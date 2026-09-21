-- ~/.config/nvim/lua/ramtin/init.lua
--
-- Loaded only when NOT inside vscode-neovim (your top-level init.lua already
-- branches on vim.g.vscode), which is why every `enabled = isNotVSCode` from
-- the old config is gone -- it was dead code.
--
-- Requires Neovim 0.11+. Check with :version

---------------------------------------------------------------------------
-- Leader. Must come before lazy.nvim loads anything.
---------------------------------------------------------------------------
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

---------------------------------------------------------------------------
-- Options
---------------------------------------------------------------------------
local o = vim.opt

o.number = true
o.relativenumber = true
o.scrolloff = 8
o.signcolumn = 'yes'
o.wrap = false
o.termguicolors = true
o.mouse = 'a'
o.clipboard = 'unnamedplus'
o.breakindent = true
o.undofile = true
o.swapfile = false
o.hlsearch = false
o.incsearch = true
o.ignorecase = true
o.smartcase = true
o.updatetime = 250
o.timeoutlen = 300
o.splitright = true
o.splitbelow = true
o.confirm = true
o.completeopt = 'menu,menuone,noselect'

-- Indentation. vim-sleuth adapts per project; Dart gets 2 via the autocmd below.
o.tabstop = 4
o.softtabstop = 4
o.shiftwidth = 4
o.expandtab = true
o.smartindent = true

-- Folding.
-- Your old config set foldexpr/foldtext but never set foldmethod, so folding
-- silently stayed on 'manual' and none of it did anything.
-- Also: vim.treesitter.foldtext() is deprecated -- an empty foldtext now gives
-- you the syntax-highlighted default.
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldtext = ''
o.foldlevel = 99
o.foldlevelstart = 99

---------------------------------------------------------------------------
-- Diagnostics
---------------------------------------------------------------------------
vim.diagnostic.config({
  severity_sort = true,
  underline = true,
  update_in_insert = false,
  float = { border = 'rounded', source = 'if_many' },
  virtual_text = { spacing = 2, source = 'if_many', prefix = '*' },
  signs = {
    text = {
      [vim.diagnostic.severity.ERROR] = 'E',
      [vim.diagnostic.severity.WARN] = 'W',
      [vim.diagnostic.severity.INFO] = 'I',
      [vim.diagnostic.severity.HINT] = 'H',
    },
  },
})

---------------------------------------------------------------------------
-- Keymaps
---------------------------------------------------------------------------
local map = vim.keymap.set

map({ 'n', 'v' }, '<Space>', '<Nop>', { silent = true })

-- Wrap-aware j/k
map('n', 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map('n', 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })

-- Diagnostics.
-- vim.diagnostic.goto_prev/goto_next are deprecated in 0.11 and slated for
-- removal in 0.12. vim.diagnostic.jump() replaces both.
map('n', '[d', function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = 'Previous diagnostic' })
map('n', ']d', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Next diagnostic' })
map('n', ']l', function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = 'Next diagnostic' })
map('n', '<leader>k', vim.diagnostic.open_float, { desc = 'Float diagnostic' })
map('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Diagnostics to loclist' })
-- NOTE: <leader>e moved off diagnostics -- it is the file [E]xplorer now.

-- Insert-mode navigation (kept from your config)
map('i', '<C-f>', '<Right>')
map('i', '<C-b>', '<Left>')

-- Window navigation
map('n', '<C-h>', '<C-w>h', { desc = 'Window left' })
map('n', '<C-j>', '<C-w>j', { desc = 'Window down' })
map('n', '<C-k>', '<C-w>k', { desc = 'Window up' })
map('n', '<C-l>', '<C-w>l', { desc = 'Window right' })

map('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })

---------------------------------------------------------------------------
-- Autocommands
---------------------------------------------------------------------------
local augroup = function(name) return vim.api.nvim_create_augroup('ramtin_' .. name, { clear = true }) end

-- vim.highlight.on_yank was renamed to vim.hl.on_yank in 0.11
vim.api.nvim_create_autocmd('TextYankPost', {
  group = augroup('yank'),
  callback = function() (vim.hl or vim.highlight).on_yank() end,
})

-- Dart/YAML want 2 spaces regardless of what vim-sleuth guesses
vim.api.nvim_create_autocmd('FileType', {
  group = augroup('indent'),
  pattern = { 'dart', 'yaml', 'json', 'lua' },
  callback = function()
    vim.bo.tabstop = 2
    vim.bo.softtabstop = 2
    vim.bo.shiftwidth = 2
    vim.bo.expandtab = true
  end,
})

---------------------------------------------------------------------------
-- lazy.nvim bootstrap
---------------------------------------------------------------------------
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local out = vim.fn.system({
    'git', 'clone', '--filter=blob:none', '--branch=stable',
    'https://github.com/folke/lazy.nvim.git', lazypath,
  })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { 'Failed to clone lazy.nvim:\n', 'ErrorMsg' },
      { out, 'WarningMsg' },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  spec = { { import = 'ramtin.plugins' } },
  install = { colorscheme = { 'tomorrow-night', 'habamax' } },
  checker = { enabled = true, notify = false },
  change_detection = { notify = false },
  performance = {
    rtp = {
      -- netrw is disabled because neo-tree takes over file browsing
      disabled_plugins = { 'gzip', 'tarPlugin', 'tohtml', 'zipPlugin', 'netrwPlugin', 'tutor' },
    },
  },
})

-- Neovide tweak
if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
end
