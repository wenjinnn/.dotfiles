-- nvim debug
local in_vscode = require("util").in_vscode
if in_vscode() then
  return
end
local add, later = MiniDeps.add, MiniDeps.later
later(function()
  add({
    source = "mfussenegger/nvim-dap",
    depends = {
      "theHamsta/nvim-dap-virtual-text",
      "mfussenegger/nvim-dap-python",
    },
  })
  local dap = require("dap")
  local api = vim.api
  local util = require("util")
  local map = util.map
  local repeatable = util.make_repeatable_keymap
  local dap_ui_widgets = require("dap.ui.widgets")
  local dap_cursor_float = function(widget, title)
    dap_ui_widgets.cursor_float(widget, { title = title })
  end

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
  require("dap-python").setup("python")
  require("nvim-dap-virtual-text").setup({
    all_frames = true, virt_text_pos = "eol",
  })

  map("n", "<leader>db", dap.toggle_breakpoint, "Dap toggle breakpoint")
  map("n", "<leader>dd", dap.clear_breakpoints, "Dap clear breakpoint")
  map("n", "<leader>dr", dap.run_last, "Dap run last")
  map("n", "<leader>dC",
    repeatable("n", "<plug>(DapRunToCursor)", function()
      dap.run_to_cursor()
    end),
    "Dap run to cursor")
  map("n", "<leader>do",
    repeatable("n", "<plug>(DapStepOver)", function()
      dap.step_over()
    end),
    "Dap step over")
  map("n", "<leader>dp",
    repeatable("n", "<plug>(DapStepBack)", function()
      dap.step_back()
    end),
    "Dap step back")
  map("n", "<leader>di",
    repeatable("n", "<plug>(DapStepInto)", function()
      dap.step_into()
    end),
    "Dap step into")
  map("n", "<leader>dO",
    repeatable("n", "<plug>(DapStepOut)", function()
      dap.step_out()
    end),
    "Dap step out")
  map("n",
    "<leader>de",
    repeatable("n", "<plug>(DapReverseContinue)", function()
      dap.reverse_continue()
    end),
    "Dap reverse continue")
  map("n", "<leader>dq",
    function()
      dap.list_breakpoints()
      vim.cmd("copen")
    end, "Dap list breakpoints")
  map("n", "<leader>dc",
    function()
      -- fix java dap setup failed sometime
      if vim.bo.filetype == "java" and require("dap").configurations.java == nil then
        require("lsp.jdtls").setup_dap()
      end
      dap.continue()
    end,
    "Dap continue")
  map("n", "<leader>dB",
    function()
      dap.set_breakpoint(vim.fn.input("Breakpoint condition: "))
    end,
    "Dap condition breakpoint")
  map("n", "<leader>dl",
    function()
      dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end,
    "Dap log breakpoint")
  map("n", "<leader>dE",
    function()
      dap.set_exception_breakpoints("default")
    end,
    "Dap exception breakpoint")
  map("n", "<leader>dR",
    function()
      dap.repl.toggle()
      vim.cmd("wincmd p")
      local filetype = vim.api.nvim_get_option_value("filetype", { buf = 0 })
      if filetype == "dap-repl" then
        vim.cmd("startinsert")
      end
    end,
    "Dap repl toggle")
  map("n", "<leader>ds",
    function()
      dap_cursor_float(dap_ui_widgets.scopes, "dap-scopes")
    end,
    "Dap scopes")
  map("n", "<leader>df",
    function()
      dap_cursor_float(dap_ui_widgets.frames, "dap-frames")
    end,
    "Dap frames")
  map("n", "<leader>de",
    function()
      dap_cursor_float(dap_ui_widgets.expression, "dap-expression")
    end,
    "Dap expression")
  map("n", "<leader>dt",
    function()
      dap_cursor_float(dap_ui_widgets.threads, "dap-threads")
    end,
    "Dap threads")
  map("n", "<leader>dS",
    function()
      dap_cursor_float(dap_ui_widgets.sessions, "dap-sessions")
    end,
    "Dap sessions")
  map("n", "<leader>dh",
    function()
      dap_ui_widgets.hover("<cexpr>", { title = "dap-hover" })
    end,
    "Dap hover")
end)
