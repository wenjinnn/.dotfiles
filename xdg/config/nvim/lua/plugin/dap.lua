local not_vscode = require("util").not_vscode
-- nvim debug
return {
  "mfussenegger/nvim-dap",
  cond = not_vscode,
  dependencies = {
    "theHamsta/nvim-dap-virtual-text",
    opts = { all_frames = true },
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
        end,
      })
      new_term:toggle()
      return new_term.bufnr, new_term.window
    end

    -- dap repl completion, we use cmp-dap now
    -- vim.api.nvim_create_autocmd("FileType", {
    --   pattern = "dap-repl",
    --   callback = function(args)
    --     require("dap.ext.autocompl").attach()
    --   end,
    -- })

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
    return {
      { "<leader>db", dap.toggle_breakpoint, desc = "Dap Toggle Breakpoint" },
      {
        "<leader>dq",
        function()
          dap.list_breakpoints()
          vim.cmd("copen")
        end,
        desc = "Dap List Breakpoints",
      },
      { "<leader>dd", dap.clear_breakpoints, desc = "Dap Clear Breakpoint" },
      { "<leader>dc", dap.continue, desc = "Dap Continue" },
      {
        "<leader>dC",
        repeatable("n", "<plug>(DapRunToCursor)", dap.run_to_cursor),
        desc = "Dap Run To Cursor",
      },
      {
        "<leader>do",
        repeatable("n", "<plug>(DapStepOver)", dap.step_over),
        desc = "Dap Step Over",
      },
      {
        "<leader>dp",
        repeatable("n", "<plug>(DapStepBack)", dap.step_back),
        desc = "Dap Step Back",
      },
      {
        "<leader>di",
        repeatable("n", "<plug>(DapStepInto)", dap.step_into),
        desc = "Dap Step Into",
      },
      { "<leader>dO", repeatable("n", "<plug>(DapStepOut)", dap.step_out), desc = "Dap Step Out" },
      {
        "<leader>de",
        repeatable("n", "<plug>(DapReverseContinue)", dap.reverse_continue),
        desc = "Dap Reverse Continue",
      },
      { "<leader>dB", dap_condition_breakpoint, desc = "Dap Condition Breakpoint" },
      { "<leader>dl", dap_log_breakpoint, desc = "Dap Log Breakpoint" },
      { "<leader>dE", dap_exception_breakpoint, desc = "Dap Exception Breakpoint" },
      { "<leader>dR", dap.repl.toggle, desc = "Dap Repl Toggle" },
      { "<leader>dr", dap.run_last, desc = "Dap Run Last" },
      { "<leader>ds", dap_scopes, desc = "Dap Scopes" },
      { "<leader>df", dap_frames, desc = "Dap Frames" },
      { "<leader>de", dap_expression, desc = "Dap Expression" },
      { "<leader>dt", dap_threads, desc = "Dap Threads" },
      { "<leader>dS", dap_sessions, desc = "Dap Sessions" },
      { "<leader>dh", dap_hover, desc = "Dap Hover" },
    }
  end,
}
