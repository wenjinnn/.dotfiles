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
  local repeat_map = util.make_repeatable_keymap
  local widgets = require("dap.ui.widgets")
  local dap_ui = function(widget, title)
    return function()
      widgets.cursor_float(widget, { title = title })
    end
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

  vim.api.nvim_create_autocmd({ "FileType" }, {
    pattern = "dap-repl",
    group = util.augroup("dap_repl"),
    callback = function()
      require("dap.ext.autocompl").attach()
    end,
  })

  require("dap-python").setup("python")
  require("nvim-dap-virtual-text").setup({
    all_frames = true, virt_text_pos = "eol",
  })

  map("n", "<leader>db", dap.toggle_breakpoint, "Dap toggle breakpoint")
  map("n", "<leader>dd", dap.clear_breakpoints, "Dap clear breakpoint")
  map("n", "<leader>dr", dap.run_last, "Dap run last")
  repeat_map("n", "<leader>dC", dap.run_to_cursor, "Dap run to cursor")
  repeat_map("n", "<leader>do", dap.step_over, "Dap step over")
  repeat_map("n", "<leader>dp", dap.step_back, "Dap step back")
  repeat_map("n", "<leader>di", dap.step_into, "Dap step into")
  repeat_map("n", "<leader>dO", dap.step_out, "Dap step out")
  repeat_map("n", "<leader>de", dap.reverse_continue, "Dap reverse continue")
  map("n", "<leader>ds", dap_ui(widgets.scopes, "dap-scopes"), "Dap scopes")
  map("n", "<leader>df", dap_ui(widgets.frames, "dap-frames"), "Dap frames")
  map("n", "<leader>de", dap_ui(widgets.expression, "dap-expression"), "Dap expression")
  map("n", "<leader>dt", dap_ui(widgets.threads, "dap-threads"), "Dap threads")
  map("n", "<leader>dS", dap_ui(widgets.sessions, "dap-sessions"), "Dap sessions")
  map("n", "<leader>dq",
    function()
      dap.list_breakpoints()
      vim.cmd("copen")
    end,
    "Dap list breakpoints")
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
  map("n", "<leader>dh",
    function()
      widgets.hover("<cexpr>", { title = "dap-hover" })
    end,
    "Dap hover")
end)
