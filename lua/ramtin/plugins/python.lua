-- ~/.config/nvim/lua/ramtin/plugins/python.lua
--
-- Language servers (basedpyright + ruff) live in lsp.lua with the others.
-- This file holds Python debugging.
--
-- debugpy comes from Mason:  :MasonInstall debugpy
-- dap-python only uses Mason's copy to run the debug adapter. The program
-- being debugged runs with $VIRTUAL_ENV, or ./.venv / ./venv if present,
-- so your project's dependencies are importable.

return {
  {
    'mfussenegger/nvim-dap-python',
    ft = 'python',
    dependencies = { 'mfussenegger/nvim-dap' },
    keys = {
      { '<leader>dt', function() require('dap-python').test_method() end,     ft = 'python', desc = '[D]ebug: nearest [T]est' },
      { '<leader>dc', function() require('dap-python').test_class() end,      ft = 'python', desc = '[D]ebug: test [C]lass' },
      { '<leader>dv', function() require('dap-python').debug_selection() end, ft = 'python', mode = 'v', desc = '[D]ebug: selection' },
    },
    config = function()
      local debugpy = vim.fn.stdpath('data') .. '/mason/packages/debugpy/venv/bin/python'
      if vim.fn.executable(debugpy) == 0 then
        vim.notify('debugpy not found. Run :MasonInstall debugpy', vim.log.levels.WARN)
        return
      end
      require('dap-python').setup(debugpy)
      require('dap-python').test_runner = 'pytest'
    end,
  },
}
