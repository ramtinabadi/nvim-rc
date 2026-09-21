-- ~/.config/nvim/lua/ramtin/plugins/flutter.lua
--
-- This is the replacement for the VS Code Dart/Flutter extension.
--
-- Two settings in here directly target the 978 MB analysis server:
--
--   root_patterns = { 'pubspec.yaml' }
--       The default is { '.git', 'pubspec.yaml' }. In a monorepo, '.git' wins
--       at the repo root and the analysis server loads every package in the
--       repo. Dropping '.git' scopes it to the innermost package containing
--       the file you opened, plus its path dependencies.
--       Trade-off: repo-wide "find all references" and rename stop at that
--       boundary. If you refactor across packages often, add '.git' back.
--
--   analysisExcludedFolders
--       Keeps the pub cache and the Flutter SDK out of the analysis roots.
--       Go-to-definition into a package still works; they just aren't
--       indexed up front.

return {
  {
    'nvim-flutter/flutter-tools.nvim',
    ft = { 'dart' },
    cmd = {
      'FlutterRun', 'FlutterDevices', 'FlutterEmulators', 'FlutterReload',
      'FlutterRestart', 'FlutterQuit', 'FlutterOutlineToggle', 'FlutterDevTools',
    },
    dependencies = {
      'nvim-lua/plenary.nvim',
      'mfussenegger/nvim-dap',
      'nvim-telescope/telescope.nvim',
    },
    keys = {
      { '<leader>Fr', '<cmd>FlutterRun<cr>',           desc = 'Flutter: [R]un' },
      { '<leader>FR', '<cmd>FlutterRestart<cr>',       desc = 'Flutter: hot [R]estart' },
      { '<leader>Fh', '<cmd>FlutterReload<cr>',        desc = 'Flutter: [H]ot reload' },
      { '<leader>Fq', '<cmd>FlutterQuit<cr>',          desc = 'Flutter: [Q]uit app' },
      { '<leader>Fd', '<cmd>FlutterDevices<cr>',       desc = 'Flutter: [D]evices' },
      { '<leader>Fe', '<cmd>FlutterEmulators<cr>',     desc = 'Flutter: [E]mulators' },
      { '<leader>Fo', '<cmd>FlutterOutlineToggle<cr>', desc = 'Flutter: widget [O]utline' },
      { '<leader>Ft', '<cmd>FlutterDevTools<cr>',      desc = 'Flutter: Dev[T]ools' },
      { '<leader>Fl', '<cmd>FlutterLogToggle<cr>',     desc = 'Flutter: dev [L]og' },
      { '<leader>Fc', '<cmd>Telescope flutter commands<cr>', desc = 'Flutter: [C]ommands' },
    },
    config = function()
      local ok_blink, blink = pcall(require, 'blink.cmp')
      local capabilities = ok_blink and blink.get_lsp_capabilities({}, true)
        or vim.lsp.protocol.make_client_capabilities()

      require('flutter-tools').setup({
        -- Monorepo scoping. See the note at the top of this file.
        root_patterns = { 'pubspec.yaml' },

        ui = { border = 'rounded', notification_style = 'native' },

        -- Feeds the device / app version into lualine (see ui.lua)
        decorations = {
          statusline = { app_version = true, device = true, project_config = true },
        },

        widget_guides = { enabled = true },

        -- The "// Text" markers VS Code shows at the end of a closing paren
        closing_tags = { enabled = true, highlight = 'Comment', prefix = '// ' },

        -- `flutter run` output in a split
        dev_log = { enabled = true, filter = nil, open_cmd = 'botright 15split' },

        -- DevTools runs in the browser, same as it does from VS Code.
        -- autostart is off so you don't pay for it on every run.
        dev_tools = { autostart = false, auto_open_browser = false },

        outline = { open_cmd = '30vnew', auto_open = false },

        debugger = {
          enabled = true,
          run_via_dap = true,
          exception_breakpoints = {},
          evaluate_to_string_in_debug_views = true,
          register_configurations = function(_)
            local dap = require('dap')
            dap.configurations.dart = dap.configurations.dart or {}
            -- Reuses .vscode/launch.json if your monorepo already has one,
            -- so flavors and --dart-define args carry over.
            pcall(function()
              require('dap.ext.vscode').load_launchjs(nil, { dart = { 'dart' }, flutter = { 'dart' } })
            end)
          end,
        },

        -- Set to true if you manage SDK versions with fvm
        fvm = false,

        lsp = {
          capabilities = capabilities,
          color = { enabled = true, background = false, virtual_text = true },
          settings = {
            showTodos = true,
            completeFunctionCalls = true,
            enableSnippets = true,
            updateImportsOnRename = true,
            renameFilesWithClasses = 'prompt',
            analysisExcludedFolders = {
              vim.fn.expand('$HOME/.pub-cache'),
              vim.fn.expand('$HOME/fvm'),
              vim.fn.expand('$HOME/flutter'),
              vim.fn.expand('$HOME/development/flutter'),
            },
          },
        },
      })

      pcall(function() require('telescope').load_extension('flutter') end)
    end,
  },

  -- Debug adapter
  {
    'mfussenegger/nvim-dap',
    dependencies = {
      { 'rcarriga/nvim-dap-ui', dependencies = { 'nvim-neotest/nvim-nio' } },
      'theHamsta/nvim-dap-virtual-text',
    },
    keys = {
      { '<F5>',       function() require('dap').continue() end,          desc = 'Debug: Continue' },
      { '<F10>',      function() require('dap').step_over() end,         desc = 'Debug: Step Over' },
      { '<F11>',      function() require('dap').step_into() end,         desc = 'Debug: Step Into' },
      { '<F12>',      function() require('dap').step_out() end,          desc = 'Debug: Step Out' },
      { '<leader>db', function() require('dap').toggle_breakpoint() end, desc = '[D]ebug: Toggle [B]reakpoint' },
      {
        '<leader>dB',
        function() require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
        desc = '[D]ebug: Conditional [B]reakpoint',
      },
      { '<leader>du', function() require('dapui').toggle() end,          desc = '[D]ebug: Toggle [U]I' },
      { '<leader>dr', function() require('dap').repl.toggle() end,       desc = '[D]ebug: [R]EPL' },
    },
    config = function()
      local dap = require('dap')
      local dapui = require('dapui')

      dapui.setup({
        icons = { expanded = 'v', collapsed = '>', current_frame = '*' },
        controls = { icons = {
          pause = '||', play = '>', step_into = 'i', step_over = 'o',
          step_out = 'u', step_back = 'b', run_last = 'r', terminate = 'x', disconnect = 'd',
        } },
      })

      require('nvim-dap-virtual-text').setup({ commented = true })

      vim.fn.sign_define('DapBreakpoint', { text = 'B', texthl = 'DiagnosticError', numhl = '' })
      vim.fn.sign_define('DapStopped', { text = '>', texthl = 'DiagnosticWarn', numhl = '' })

      dap.listeners.after.event_initialized['dapui_config'] = dapui.open
      dap.listeners.before.event_terminated['dapui_config'] = dapui.close
      dap.listeners.before.event_exited['dapui_config'] = dapui.close
    end,
  },
}
