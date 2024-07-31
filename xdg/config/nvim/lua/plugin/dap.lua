local not_vscode = require("util").not_vscode
local api = vim.api
local util = require("util")
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
      local cur_win = api.nvim_get_current_win()
      api.nvim_command("tabnew")
      local bufnr = api.nvim_get_current_buf()
      util.setup_term_opt(bufnr)
      local win = api.nvim_get_current_win()
      api.nvim_set_current_win(cur_win)
      return bufnr, win
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
    local repeatable = util.make_repeatable_keymap
    local dap_cursor_float = function(widget, title)
      require("dap.ui.widgets").cursor_float(widget, { title = title })
    end
    return {
      {
        "<leader>db",
        function()
          require("dap").toggle_breakpoint()
        end,
        desc = "Dap toggle breakpoint",
      },
      {
        "<leader>dq",
        function()
          require("dap").list_breakpoints()
          vim.cmd("copen")
        end,
        desc = "Dap list breakpoints",
      },
      {
        "<leader>dd",
        function()
          require("dap").clear_breakpoints()
        end,
        desc = "Dap clear breakpoint",
      },
      {
        "<leader>dc",
        function()
          -- fix java dap setup failed sometime
          if vim.bo.filetype == "java" and require("dap").configurations.java == nil then
            require("lsp.jdtls").setup_dap()
          end
          require("dap").continue()
        end,
        desc = "Dap continue",
      },
      {
        "<leader>dC",
        repeatable("n", "<plug>(DapRunToCursor)", function()
          require("dap").run_to_cursor()
        end),
        desc = "Dap run to cursor",
      },
      {
        "<leader>do",
        repeatable("n", "<plug>(DapStepOver)", function()
          require("dap").step_over()
        end),
        desc = "Dap step over",
      },
      {
        "<leader>dp",
        repeatable("n", "<plug>(DapStepBack)", function()
          require("dap").step_back()
        end),
        desc = "Dap step back",
      },
      {
        "<leader>di",
        repeatable("n", "<plug>(DapStepInto)", function()
          require("dap").step_into()
        end),
        desc = "Dap step into",
      },
      {
        "<leader>dO",
        repeatable("n", "<plug>(DapStepOut)", function()
          require("dap").step_out()
        end),
        desc = "Dap step out",
      },
      {
        "<leader>de",
        repeatable("n", "<plug>(DapReverseContinue)", function()
          require("dap").reverse_continue()
        end),
        desc = "Dap reverse continue",
      },
      {
        "<leader>dB",
        function()
          require("dap").set_breakpoint(vim.fn.input("Breakpoint condition: "))
        end,
        desc = "Dap condition breakpoint",
      },
      {
        "<leader>dl",
        function()
          require("dap").set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
        end,
        desc = "Dap log breakpoint",
      },
      {
        "<leader>dE",
        function()
          require("dap").set_exception_breakpoints("default")
        end,
        desc = "Dap exception breakpoint",
      },
      {
        "<leader>dR",
        function()
          require("dap").repl.toggle()
          vim.cmd("wincmd p")
          local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
          if filetype == "dap-repl" then
            vim.cmd("startinsert")
          end
        end,
        desc = "Dap repl toggle",
      },
      {
        "<leader>dr",
        function()
          require("dap").run_last()
        end,
        desc = "Dap run last",
      },
      {
        "<leader>ds",
        function()
          dap_cursor_float(require("dap.ui.widgets").scopes, "dap-scopes")
        end,
        desc = "Dap scopes",
      },
      {
        "<leader>df",
        function()
          dap_cursor_float(require("dap.ui.widgets").frames, "dap-frames")
        end,
        desc = "Dap frames",
      },
      {
        "<leader>de",
        function()
          dap_cursor_float(require("dap.ui.widgets").expression, "dap-expression")
        end,
        desc = "Dap expression",
      },
      {
        "<leader>dt",
        function()
          dap_cursor_float(require("dap.ui.widgets").threads, "dap-threads")
        end,
        desc = "Dap threads",
      },
      {
        "<leader>dS",
        function()
          dap_cursor_float(require("dap.ui.widgets").sessions, "dap-sessions")
        end,
        desc = "Dap sessions",
      },
      {
        "<leader>dh",
        function()
          require("dap.ui.widgets").hover("<cexpr>", { title = "dap-hover" })
        end,
        desc = "Dap hover",
      },
    }
  end,
}
