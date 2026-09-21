-- ~/.config/nvim/lua/ramtin/plugins/lsp.lua
--
-- What changed from your old config, and why:
--
--   * williamboman/mason.nvim    -> mason-org/mason.nvim  (repo moved in 2025)
--   * mason-lspconfig.setup_handlers() was REMOVED in mason-lspconfig v2.
--     That single call was the main thing breaking your LSP setup.
--   * folke/neodev.nvim is deprecated -> folke/lazydev.nvim
--   * Server setup now uses Neovim 0.11's native vim.lsp.config/vim.lsp.enable.
--     nvim-lspconfig is still installed, but only to supply the server
--     definitions that vim.lsp.config reads.
--   * nvim-cmp + LuaSnip + cmp_luasnip + cmp-nvim-lsp + cmp-path -> blink.cmp
--     (one plugin, one opts block, and a Rust matcher instead of Lua)
--
-- dartls is deliberately absent here. flutter-tools.nvim starts and owns the
-- Dart analysis server itself -- configuring it in both places gives you two
-- analysis server processes, which is the opposite of what you want.

return {
  {
    'mason-org/mason.nvim',
    cmd = { 'Mason', 'MasonInstall', 'MasonUpdate' },
    opts = { ui = { border = 'rounded' } },
  },

  -- Lua development for your own Neovim config
  {
    'folke/lazydev.nvim',
    ft = 'lua',
    opts = {
      library = {
        { path = '${3rd}/luv/library', words = { 'vim%.uv' } },
      },
    },
  },

  -- Completion
  {
    'saghen/blink.cmp',
    event = { 'InsertEnter', 'CmdlineEnter' },
    version = '1.*',
    dependencies = { 'rafamadriz/friendly-snippets' },
    opts = {
      keymap = {
        preset = 'default',
        ['<CR>'] = { 'accept', 'fallback' },
        ['<Tab>'] = { 'select_next', 'snippet_forward', 'fallback' },
        ['<S-Tab>'] = { 'select_prev', 'snippet_backward', 'fallback' },
        ['<C-n>'] = { 'select_next', 'fallback' },
        ['<C-p>'] = { 'select_prev', 'fallback' },
        ['<C-Space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      },
      appearance = { nerd_font_variant = 'mono' },
      completion = {
        menu = { border = 'rounded' },
        documentation = { auto_show = true, auto_show_delay_ms = 200, window = { border = 'rounded' } },
        -- Dart's analysis server returns a lot of auto-import candidates;
        -- this keeps the list from reordering under you as you type.
        list = { selection = { preselect = true, auto_insert = false } },
      },
      signature = { enabled = true, window = { border = 'rounded' } },
      sources = { default = { 'lsp', 'path', 'snippets', 'buffer' } },
      fuzzy = { implementation = 'prefer_rust_with_warning' },
    },
    opts_extend = { 'sources.default' },
  },

  -- LSP
  {
    'neovim/nvim-lspconfig',
    event = { 'BufReadPre', 'BufNewFile' },
    dependencies = { 'mason-org/mason.nvim', 'saghen/blink.cmp' },
    config = function()
      -- Shared keymaps for every attached server, dartls included.
      -- An LspAttach autocmd replaces the old per-server on_attach function.
      vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('ramtin_lsp_attach', { clear = true }),
        callback = function(event)
          local bufnr = event.buf
          local function nmap(keys, func, desc)
            vim.keymap.set('n', keys, func, { buffer = bufnr, desc = 'LSP: ' .. desc })
          end

          local builtin = require('telescope.builtin')
          nmap('gd', builtin.lsp_definitions, '[G]oto [D]efinition')
          nmap('gr', builtin.lsp_references, '[G]oto [R]eferences')
          nmap('gI', builtin.lsp_implementations, '[G]oto [I]mplementation')
          nmap('<leader>D', builtin.lsp_type_definitions, 'Type [D]efinition')
          nmap('<leader>ds', builtin.lsp_document_symbols, '[D]ocument [S]ymbols')
          nmap('<leader>ws', builtin.lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
          nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
          nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
          nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
          nmap('K', function() vim.lsp.buf.hover({ border = 'rounded' }) end, 'Hover Documentation')
          nmap('<C-s>', function() vim.lsp.buf.signature_help({ border = 'rounded' }) end, 'Signature Help')

          vim.api.nvim_buf_create_user_command(bufnr, 'Format', function()
            vim.lsp.buf.format({ async = true })
          end, { desc = 'Format buffer via LSP' })

          -- Inlay hints, toggleable
          local client = vim.lsp.get_client_by_id(event.data.client_id)
          if client and client:supports_method('textDocument/inlayHint') then
            nmap('<leader>th', function()
              vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = bufnr }), { bufnr = bufnr })
            end, '[T]oggle inlay [H]ints')
          end
        end,
      })

      -- Give every server blink's completion capabilities
      vim.lsp.config('*', {
        capabilities = require('blink.cmp').get_lsp_capabilities({}, true),
      })

      vim.lsp.config('lua_ls', {
        settings = {
          Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
            completion = { callSnippet = 'Replace' },
          },
        },
      })

      -- Python: basedpyright for types/navigation, ruff for lint/format/imports.
      -- Both are in Mason: :MasonInstall basedpyright ruff
      local function python_path(root)
        if vim.env.VIRTUAL_ENV then
          return vim.env.VIRTUAL_ENV .. '/bin/python'
        end
        for _, dir in ipairs({ '.venv', 'venv', 'env' }) do
          local candidate = root .. '/' .. dir .. '/bin/python'
          if vim.fn.executable(candidate) == 1 then return candidate end
        end
        return vim.fn.exepath('python3')
      end

      vim.lsp.config('basedpyright', {
        -- Point basedpyright at the project's venv (uv/poetry/venv all create
        -- .venv by default) so third-party imports resolve without a
        -- pyrightconfig.json in every project.
        before_init = function(_, config)
          if not config.root_dir then return end
          config.settings = vim.tbl_deep_extend('force', config.settings or {}, {
            python = { pythonPath = python_path(config.root_dir) },
          })
        end,
        settings = {
          basedpyright = {
            -- ruff owns import sorting; two organize-imports actions just fight
            disableOrganizeImports = true,
            analysis = {
              -- basedpyright's default ('recommended') is very noisy
              typeCheckingMode = 'standard',
              autoImportCompletions = true,
              diagnosticMode = 'openFilesOnly',
            },
          },
        },
      })

      vim.lsp.config('ruff', {
        on_attach = function(client, bufnr)
          -- basedpyright's hover is the useful one; ruff's only covers noqa codes
          client.server_capabilities.hoverProvider = false
          vim.keymap.set('n', '<leader>co', function()
            vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' }, diagnostics = {} }, apply = true })
          end, { buffer = bufnr, desc = 'LSP: [O]rganize imports' })
        end,
      })

      -- Add more servers here as you need them (install the binary with :Mason)
      vim.lsp.enable({ 'lua_ls', 'basedpyright', 'ruff' })
    end,
  },
}
