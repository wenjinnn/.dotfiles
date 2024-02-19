local util = require('util')
-- nvim debug
return {
  'mfussenegger/nvim-dap',
  cond = not vim.g.vscode,
  config = function()
    local dap = require('dap')
    -- dap.defaults.fallback.terminal_win_cmd = 'enew'
    dap.defaults.fallback.terminal_win_cmd = function ()
      local Terminal = require('toggleterm.terminal').Terminal
      local new_term = Terminal:new({
        -- start zsh without rc file
        env = { ['IS_NVIM_DAP_TOGGLETERM'] = 1},
        clear_env = true
      })
      new_term:toggle()
      return new_term.bufnr, new_term.window
    end

    -- dap repl completion
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "dap-repl",
      callback = function(args)
        require('dap.ext.autocompl').attach()
      end,
    })
  end
}
