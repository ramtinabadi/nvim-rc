-- ~/.config/nvim/lua/ramtin/plugins/ui.lua

return {
  -- Colourscheme
  {
    'Ardakilic/vim-tomorrow-night-theme',
    lazy = false,
    priority = 1000,
    config = function()
      vim.cmd.colorscheme('tomorrow-night')
    end,
  },

  -- File explorer. This is the VS Code sidebar equivalent.
  {
    'nvim-neo-tree/neo-tree.nvim',
    branch = 'v3.x',
    cmd = 'Neotree',
    keys = {
      { '<leader>e', '<cmd>Neotree toggle reveal left<cr>', desc = 'File [E]xplorer' },
      { '<leader>E', '<cmd>Neotree reveal left<cr>',        desc = 'Reveal current file in explorer' },
      { '<leader>gs', '<cmd>Neotree git_status left<cr>',   desc = '[G]it [S]tatus tree' },
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'MunifTanjim/nui.nvim',
    },
    -- netrw is disabled in init.lua, so nothing handles `nvim .` unless
    -- neo-tree is already loaded. This forces it to load early, but only
    -- when the argument really is a directory -- normal `nvim file.dart`
    -- still gets lazy loading.
    init = function()
      if vim.fn.argc(-1) == 1 then
        local stat = (vim.uv or vim.loop).fs_stat(vim.fn.argv(0))
        if stat and stat.type == 'directory' then
          require('neo-tree')
        end
      end
    end,
    opts = {
      close_if_last_window = true,
      popup_border_style = 'rounded',
      enable_git_status = true,
      enable_diagnostics = true,
      sources = { 'filesystem', 'buffers', 'git_status' },
      source_selector = {
        winbar = true,
        sources = {
          { source = 'filesystem', display_name = ' Files ' },
          { source = 'buffers',    display_name = ' Bufs ' },
          { source = 'git_status', display_name = ' Git ' },
        },
      },
      default_component_configs = {
        indent = { with_expanders = true, expander_collapsed = '>', expander_expanded = 'v' },
        git_status = {
          symbols = {
            added = 'A', modified = 'M', deleted = 'D', renamed = 'R',
            untracked = '?', ignored = 'i', unstaged = 'U', staged = 'S', conflict = 'C',
          },
        },
      },
      window = {
        width = 34,
        mappings = {
          ['<space>'] = 'none', -- don't steal the leader key
          ['l'] = 'open',
          ['h'] = 'close_node',
          ['H'] = 'toggle_hidden',
          ['<cr>'] = 'open',
          ['o'] = 'open',
          ['s'] = 'open_split',
          ['v'] = 'open_vsplit',
        },
      },
      filesystem = {
        -- Mirrors VS Code: the tree follows whatever buffer you're in
        follow_current_file = { enabled = true, leave_dirs_open = true },
        use_libuv_file_watcher = true,
        hijack_netrw_behavior = 'open_current',
        filtered_items = {
          visible = false,
          hide_dotfiles = false,
          hide_gitignored = true,
          always_show = { '.env', '.gitignore', '.github' },
          -- Flutter build noise. Hiding these also keeps the tree responsive
          -- in a monorepo with many packages.
          hide_by_name = { '.dart_tool', '.DS_Store', 'build', '.gradle', '.idea' },
        },
      },
    },
  },

  -- Statusline
  {
    'nvim-lualine/lualine.nvim',
    event = 'VeryLazy',
    dependencies = { 'nvim-tree/nvim-web-devicons' },
    opts = {
      options = {
        icons_enabled = false,
        theme = 'auto', -- was 'onedark' while your colourscheme was tomorrow-night
        component_separators = '|',
        section_separators = '',
        globalstatus = true,
      },
      sections = {
        lualine_c = {
          { 'filename', path = 1 },
          -- flutter-tools publishes the running device / app version here
          function() return vim.g.flutter_tools_decorations and vim.g.flutter_tools_decorations.app_version or '' end,
          function() return vim.g.flutter_tools_decorations and vim.g.flutter_tools_decorations.device
              and vim.g.flutter_tools_decorations.device.name or '' end,
        },
      },
    },
  },

  -- Bufferline
  {
    'willothy/nvim-cokeline',
    event = 'VeryLazy',
    dependencies = {
      'nvim-lua/plenary.nvim',
      'nvim-tree/nvim-web-devicons',
      'stevearc/resession.nvim',
    },
    config = true,
  },

  -- Indent guides
  {
    'lukas-reineke/indent-blankline.nvim',
    event = { 'BufReadPost', 'BufNewFile' },
    main = 'ibl',
    opts = {
      indent = { char = '|' },
      scope = { enabled = false },
      exclude = { filetypes = { 'help', 'lazy', 'mason', 'neo-tree', 'dashboard' } },
    },
  },

  -- Keybinding hints.
  -- which-key v3 removed .register(); the spec goes in opts now, and your old
  -- register() calls would throw on startup.
  {
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      preset = 'helix',
      spec = {
        { '<leader>c', group = '[C]ode' },
        { '<leader>d', group = '[D]ocument / [D]ebug' },
        { '<leader>F', group = '[F]lutter' },
        { '<leader>g', group = '[G]it' },
        { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
        { '<leader>r', group = '[R]ename' },
        { '<leader>s', group = '[S]earch' },
        { '<leader>t', group = '[T]oggle' },
        { '<leader>w', group = '[W]orkspace' },
      },
    },
  },

  -- LSP progress toasts
  { 'j-hui/fidget.nvim', event = 'LspAttach', opts = {} },

  -- Minimap. Shows LSP diagnostics, gitsigns hunks and search matches.
  -- Pure Lua, no external binary. The plugin handles its own lazy loading.
  {
    'Isrothy/neominimap.nvim',
    version = 'v3.x.x',
    lazy = false,
    keys = {
      { '<leader>tm', '<cmd>Neominimap Toggle<cr>',      desc = '[T]oggle [M]inimap' },
      { '<leader>tM', '<cmd>Neominimap ToggleFocus<cr>', desc = 'Focus [M]inimap' },
    },
    init = function()
      -- The minimap floats over the right edge of each window. This keeps the
      -- cursor from scrolling underneath it on long lines.
      vim.opt.sidescrolloff = 36

      -- tomorrow-night doesn't define diagnostic colours, so the minimap
      -- inherits Neovim's pastel red/yellow, which are hard to tell apart.
      -- Re-applied on ColorScheme because :colorscheme clears highlights.
      local function minimap_colors()
        local hl = vim.api.nvim_set_hl
        hl(0, 'NeominimapErrorIcon', { fg = '#ff5555' })
        hl(0, 'NeominimapWarnIcon',  { fg = '#f0c674' })
        hl(0, 'NeominimapInfoIcon',  { fg = '#81a2be' })
        hl(0, 'NeominimapHintIcon',  { fg = '#8abeb7' })
      end
      minimap_colors()
      vim.api.nvim_create_autocmd('ColorScheme', {
        group = vim.api.nvim_create_augroup('ramtin_minimap_colors', { clear = true }),
        callback = minimap_colors,
      })

      vim.g.neominimap = {
        auto_enable = true,
        exclude_filetypes = { 'help', 'lazy', 'mason', 'neo-tree', 'dapui_scopes', 'dapui_watches', 'dapui_stacks', 'dapui_breakpoints', 'dap-repl' },
        click = { enabled = true },
        -- 'icon' mode puts one character in the minimap's sign column.
        -- ('line' paints the whole row; 'sign' draws a single braille dot.)
        -- Plain Unicode on purpose: the default icons need a Nerd Font.
        diagnostic = {
          enabled = true,
          mode = 'icon',
          icon = { ERROR = '●', WARN = '●', INFO = '•', HINT = '•' },
        },
        git = {
          enabled = true,
          mode = 'icon',
          icon = { add = '▌', change = '▌', delete = '▁' },
        },
        search = { enabled = true },
        -- Two sign columns so a diagnostic and a git bar on the same line
        -- both show, instead of the diagnostic hiding the git bar.
        winopt = function(opt) opt.signcolumn = 'auto:2' end,
      }
    end,
  },
}
