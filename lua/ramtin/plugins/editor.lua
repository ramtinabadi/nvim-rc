-- ~/.config/nvim/lua/ramtin/plugins/editor.lua

return {
  -- Detect indentation per project
  { 'tpope/vim-sleuth', event = { 'BufReadPre', 'BufNewFile' } },

  -- Buffers scoped per tab
  { 'tiagovla/scope.nvim', event = 'VeryLazy', config = true },

  -- Git
  { 'tpope/vim-fugitive', cmd = { 'Git', 'G', 'Gdiffsplit', 'Gread', 'Gwrite', 'Gblame' } },
  { 'tpope/vim-rhubarb', dependencies = { 'tpope/vim-fugitive' }, cmd = { 'GBrowse' } },

  {
    'lewis6991/gitsigns.nvim',
    event = { 'BufReadPre', 'BufNewFile' },
    opts = {
      signs = {
        add = { text = '+' },
        change = { text = '~' },
        delete = { text = '_' },
        topdelete = { text = '^' },
        changedelete = { text = '~' },
      },
      on_attach = function(bufnr)
        local gs = require('gitsigns')
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        map({ 'n', 'v' }, ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.nav_hunk('next') end)
          return '<Ignore>'
        end, { expr = true, desc = 'Next hunk' })

        map({ 'n', 'v' }, '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.nav_hunk('prev') end)
          return '<Ignore>'
        end, { expr = true, desc = 'Previous hunk' })

        map('v', '<leader>hs', function() gs.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = 'Stage hunk' })
        map('v', '<leader>hr', function() gs.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') }) end, { desc = 'Reset hunk' })
        map('n', '<leader>hs', gs.stage_hunk, { desc = 'Stage hunk' })
        map('n', '<leader>hr', gs.reset_hunk, { desc = 'Reset hunk' })
        map('n', '<leader>hS', gs.stage_buffer, { desc = 'Stage buffer' })
        map('n', '<leader>hu', gs.undo_stage_hunk, { desc = 'Undo stage hunk' })
        map('n', '<leader>hR', gs.reset_buffer, { desc = 'Reset buffer' })
        map('n', '<leader>hp', gs.preview_hunk, { desc = 'Preview hunk' })
        map('n', '<leader>hb', function() gs.blame_line({ full = false }) end, { desc = 'Blame line' })
        map('n', '<leader>hd', gs.diffthis, { desc = 'Diff against index' })
        map('n', '<leader>hD', function() gs.diffthis('~') end, { desc = 'Diff against last commit' })
        map('n', '<leader>tb', gs.toggle_current_line_blame, { desc = 'Toggle line blame' })
        map({ 'o', 'x' }, 'ih', ':<C-U>Gitsigns select_hunk<CR>', { desc = 'Select hunk' })
      end,
    },
  },

  -- Fuzzy finder
  {
    'nvim-telescope/telescope.nvim',
    branch = '0.1.x',
    cmd = 'Telescope',
    dependencies = {
      'nvim-lua/plenary.nvim',
      {
        'nvim-telescope/telescope-fzf-native.nvim',
        build = 'make',
        cond = function() return vim.fn.executable('make') == 1 end,
      },
    },
    keys = {
      { '<leader>?',       function() require('telescope.builtin').oldfiles() end,                  desc = 'Recently opened files' },
      { '<leader><space>', function() require('telescope.builtin').buffers() end,                   desc = 'Existing buffers' },
      { '<leader>sf',      function() require('telescope.builtin').find_files() end,                desc = '[S]earch [F]iles' },
      { '<leader>gf',      function() require('telescope.builtin').git_files() end,                 desc = '[G]it [F]iles' },
      { '<leader>sg',      function() require('telescope.builtin').live_grep() end,                 desc = '[S]earch by [G]rep' },
      { '<leader>sG',      '<cmd>LiveGrepGitRoot<cr>',                                              desc = '[S]earch [G]rep at git root' },
      { '<leader>sw',      function() require('telescope.builtin').grep_string() end,               desc = '[S]earch current [W]ord' },
      { '<leader>sh',      function() require('telescope.builtin').help_tags() end,                 desc = '[S]earch [H]elp' },
      { '<leader>sd',      function() require('telescope.builtin').diagnostics() end,               desc = '[S]earch [D]iagnostics' },
      { '<leader>sr',      function() require('telescope.builtin').resume() end,                    desc = '[S]earch [R]esume' },
      { '<leader>ss',      function() require('telescope.builtin').builtin() end,                   desc = '[S]earch [S]elect Telescope' },
      {
        '<leader>/',
        function()
          require('telescope.builtin').current_buffer_fuzzy_find(
            require('telescope.themes').get_dropdown({ winblend = 10, previewer = false })
          )
        end,
        desc = 'Fuzzily search in buffer',
      },
      {
        '<leader>s/',
        function()
          require('telescope.builtin').live_grep({ grep_open_files = true, prompt_title = 'Live Grep in Open Files' })
        end,
        desc = '[S]earch in open files',
      },
    },
    config = function()
      local telescope = require('telescope')
      telescope.setup({
        defaults = {
          mappings = { i = { ['<C-u>'] = false, ['<C-d>'] = false } },
          -- Keeps a Flutter monorepo's generated output out of results.
          -- Also makes live_grep noticeably faster.
          file_ignore_patterns = {
            '%.dart_tool/', 'build/', '%.git/', '%.symlinks/',
            'ios/Pods/', 'macos/Pods/', '%.freezed%.dart', '%.g%.dart',
            '__pycache__/', '%.venv/', '%.mypy_cache/', '%.pytest_cache/', '%.ruff_cache/',
          },
        },
      })
      pcall(telescope.load_extension, 'fzf')
      pcall(telescope.load_extension, 'scope')

      -- :LiveGrepGitRoot
      local function find_git_root()
        local current_file = vim.api.nvim_buf_get_name(0)
        local cwd = vim.fn.getcwd()
        local current_dir = current_file == '' and cwd or vim.fn.fnamemodify(current_file, ':h')
        local git_root = vim.fn.systemlist('git -C ' .. vim.fn.escape(current_dir, ' ') .. ' rev-parse --show-toplevel')[1]
        if vim.v.shell_error ~= 0 then
          vim.notify('Not a git repository, searching cwd', vim.log.levels.WARN)
          return cwd
        end
        return git_root
      end

      vim.api.nvim_create_user_command('LiveGrepGitRoot', function()
        require('telescope.builtin').live_grep({ search_dirs = { find_git_root() } })
      end, {})
    end,
  },

  -- Treesitter.
  --
  -- Pinned to master on purpose. nvim-treesitter moved development to the
  -- `main` branch in May 2025 and froze master; `main` drops the module system
  -- entirely (no configs.setup, no incremental selection) and much of the
  -- ecosystem is still mid-migration. master still works and is what most
  -- configs run today. Revisit in six months.
  {
    'nvim-treesitter/nvim-treesitter',
    branch = 'master',
    event = { 'BufReadPost', 'BufNewFile' },
    build = ':TSUpdate',
    dependencies = { 'nvim-treesitter/nvim-treesitter-textobjects' },
    main = 'nvim-treesitter.configs',
    opts = {
      -- Only parsers that ship prebuilt grammars. Two things to know:
      --   * there is no `gradle` parser (my mistake -- it doesn't exist)
      --   * `swift` and `objc` must be generated from grammar source, which
      --     needs the tree-sitter CLI. If you want them for the ios/ and
      --     android/ sides of your apps:
      --         brew install tree-sitter
      --     then add 'swift', 'objc' back to this list and :TSUpdate
      ensure_installed = {
        'dart', 'lua', 'luadoc', 'vim', 'vimdoc', 'query',
        'bash', 'json', 'jsonc', 'yaml', 'toml', 'markdown', 'markdown_inline',
        'c', 'cpp', 'go', 'rust', 'python', 'javascript', 'typescript', 'tsx',
        'kotlin', 'xml', 'html', 'css', 'diff', 'gitcommit',
      },
      auto_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = '<c-space>',
          node_incremental = '<c-space>',
          scope_incremental = '<c-s>',
          node_decremental = '<M-space>',
        },
      },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ['aa'] = '@parameter.outer',
            ['ia'] = '@parameter.inner',
            ['af'] = '@function.outer',
            ['if'] = '@function.inner',
            ['ac'] = '@class.outer',
            ['ic'] = '@class.inner',
          },
        },
        move = {
          enable = true,
          set_jumps = true,
          goto_next_start = { [']m'] = '@function.outer', [']]'] = '@class.outer' },
          goto_next_end = { [']M'] = '@function.outer', [']['] = '@class.outer' },
          goto_previous_start = { ['[m'] = '@function.outer', ['[['] = '@class.outer' },
          goto_previous_end = { ['[M'] = '@function.outer', ['[]'] = '@class.outer' },
        },
        swap = {
          enable = true,
          swap_next = { ['<leader>a'] = '@parameter.inner' },
          swap_previous = { ['<leader>A'] = '@parameter.inner' },
        },
      },
    },
  },
}
