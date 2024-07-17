local not_vscode = require("util").not_vscode
-- nvim debug
return {
  "mfussenegger/nvim-dap",
  cond = not_vscode,
  lazy = true,
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    opts = { all_frames = true, virt_text_pos = "eol" },
  },
  config = function()
    local dap = require("dap")
    dap.defaults.fallback.terminal_win_cmd = function()
      local Terminal = require("toggleterm.terminal").Terminal
      local new_term = Terminal:new({
        -- start zsh without rc file
        env = { ["NVIM_DAP_TOGGLETERM"] = 1 },
        clear_env = true,
        on_open = function(term)
          -- HACK dap restart session will disappear toggleterm winbar, so we reset winbar at every time we open term
          require("toggleterm.ui").set_winbar(term)
          require("util").setup_toggleterm_opt()
        end,
      })
      new_term:toggle()
      return new_term.bufnr, new_term.window
    end

    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "-i", "dap" },
    }

    dap.configurations.rust = {
      {
        name = "Launch",
        type = "gdb",
        request = "launch",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        stopAtBeginningOfMainSubprogram = false,
      },
    }
  end,
  keys = function()
    local util = require("util")
    local dap = require("dap")
    local dap_widgets = require("dap.ui.widgets")
    local repeatable = util.make_repeatable_keymap
    local dap_condition_breakpoint = function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end
    local dap_log_breakpoint = function()
      dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end
    local dap_exception_breakpoint = function()
      dap.set_exception_breakpoints("default")
    end
    local dap_hover = function()
      dap_widgets.hover("<cexpr>", { title = "dap-hover" })
    end
    local dap_cursor_float = function(widget, title)
      dap_widgets.cursor_float(widget, { title = title })
    end
    local dap_scopes = function()
      dap_cursor_float(dap_widgets.scopes, "dap-scopes")
    end
    local dap_frames = function()
      dap_cursor_float(dap_widgets.frames, "dap-frames")
    end
    local dap_expression = function()
      dap_cursor_float(dap_widgets.expression, "dap-expression")
    end
    local dap_threads = function()
      dap_cursor_float(dap_widgets.threads, "dap-threads")
    end
    local dap_sessions = function()
      dap_cursor_float(dap_widgets.sessions, "dap-sessions")
    end
    local dap_repl = function()
      dap.repl.toggle()
      vim.cmd("wincmd p")
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
      if filetype == "dap-repl" then
        vim.cmd("startinsert")
      end
    end
    return {
      { "<leader>db", dap.toggle_breakpoint, desc = "Dap toggle breakpoint" },
      {
        "<leader>dq",
        function()
          dap.list_breakpoints()
          vim.cmd("copen")
        end,
        desc = "Dap list breakpoints",
      },
      { "<leader>dd", dap.clear_breakpoints, desc = "Dap clear breakpoint" },
      { "<leader>dc", dap.continue, desc = "Dap continue" },
      {
        "<leader>dC",
        repeatable("n", "<plug>(DapRunToCursor)", dap.run_to_cursor),
        desc = "Dap run to cursor",
      },
      {
        "<leader>do",
        repeatable("n", "<plug>(DapStepOver)", dap.step_over),
        desc = "Dap step over",
      },
      {
        "<leader>dp",
        repeatable("n", "<plug>(DapStepBack)", dap.step_back),
        desc = "Dap step back",
      },
      {
        "<leader>di",
        repeatable("n", "<plug>(DapStepInto)", dap.step_into),
        desc = "Dap step into",
      },
      { "<leader>dO", repeatable("n", "<plug>(DapStepOut)", dap.step_out), desc = "Dap step out" },
      {
        "<leader>de",
        repeatable("n", "<plug>(DapReverseContinue)", dap.reverse_continue),
        desc = "Dap reverse continue",
      },
      { "<leader>dB", dap_condition_breakpoint, desc = "Dap condition breakpoint" },
      { "<leader>dl", dap_log_breakpoint, desc = "Dap log breakpoint" },
      { "<leader>dE", dap_exception_breakpoint, desc = "Dap exception breakpoint" },
      { "<leader>dR", dap_repl, desc = "Dap repl toggle" },
      { "<leader>dr", dap.run_last, desc = "Dap run last" },
      { "<leader>ds", dap_scopes, desc = "Dap scopes" },
      { "<leader>df", dap_frames, desc = "Dap frames" },
      { "<leader>de", dap_expression, desc = "Dap expression" },
      { "<leader>dt", dap_threads, desc = "Dap threads" },
      { "<leader>dS", dap_sessions, desc = "Dap sessions" },
      { "<leader>dh", dap_hover, desc = "Dap hover" },
    }
  end,
}
