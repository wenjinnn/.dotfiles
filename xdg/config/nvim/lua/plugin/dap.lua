-- nvim debug
return {
  'mfussenegger/nvim-dap',
  cond = not vim.g.vscode,
  config = function()
    local dap = require('dap')
    dap.defaults.fallback.terminal_win_cmd = function()
      local Terminal = require('toggleterm.terminal').Terminal
      local new_term = Terminal:new({
        -- start zsh without rc file
        env = { ['IS_NVIM_DAP_TOGGLETERM'] = 1 },
        clear_env = true
      })
      new_term:toggle()
      return new_term.bufnr, new_term.window
    end

    -- dap repl completion
    vim.api.nvim_create_autocmd('FileType', {
      pattern = 'dap-repl',
      callback = function(args)
        require('dap.ext.autocompl').attach()
      end,
    })
  end,
  keys = function()
    local util = require('util')
    local dap = require('dap')
    local dap_widgets = require('dap.ui.widgets')
    local repeatable = util.make_repeatable_keymap
    local dap_condition_breakpoint = function()
      dap.set_breakpoint(vim.fn.input('Breakpoint condition: '))
    end
    local dap_log_breakpoint = function()
      dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
    end
    local dap_exception_breakpoint = function()
      dap.set_exception_breakpoints('default')
    end
    local dap_hover = function()
      dap_widgets.hover('<cexpr>', { title = 'dap-hover' })
    end
    local dap_cursor_float = function(widget, title)
      dap_widgets.cursor_float(widget, { title = title })
    end
    local dap_scopes = function()
      dap_cursor_float(dap_widgets.scopes, 'dap-scopes')
    end
    local dap_frames = function()
      dap_cursor_float(dap_widgets.frames, 'dap-frames')
    end
    local dap_expression = function()
      dap_cursor_float(dap_widgets.expression, 'dap-expression')
    end
    local dap_threads = function()
      dap_cursor_float(dap_widgets.threads, 'dap-threads')
    end
    local dap_sessions = function()
      dap_cursor_float(dap_widgets.sessions, 'dap-sessions')
    end
    return {
      { '<leader>db', dap.toggle_breakpoint },
      { '<leader>dq', function()
        dap.list_breakpoints()
        vim.cmd('copen')
      end },
      { '<leader>dd', dap.clear_breakpoints },
      { '<leader>dc', dap.continue },
      { '<leader>dC', repeatable('n', '<plug>(DapRunToCursor)', dap.run_to_cursor) },
      { '<leader>do', repeatable('n', '<plug>(DapStepOver)', dap.step_over) },
      { '<leader>dp', repeatable('n', '<plug>(DapStepBack)', dap.step_back) },
      { '<leader>di', repeatable('n', '<plug>(DapStepInto)', dap.step_back) },
      { '<leader>dO', repeatable('n', '<plug>(DapStepOut)', dap.step_out) },
      { '<leader>de', repeatable('n', '<plug>(DapReverseContinue)', dap.reverse_continue) },
      { '<leader>dB', dap_condition_breakpoint },
      { '<leader>dl', dap_log_breakpoint },
      { '<leader>dE', dap_exception_breakpoint },
      { '<leader>dR', dap.repl_toggle },
      { '<leader>dr', dap.run_last },
      { '<leader>ds', dap_scopes },
      { '<leader>df', dap_frames },
      { '<leader>de', dap_expression },
      { '<leader>dt', dap_threads },
      { '<leader>dS', dap_sessions },
      { '<leader>dh', dap_hover },
    }
  end,
}
