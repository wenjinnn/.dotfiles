local M = {}
local lsp = require("util.lsp")

function M.on_attach(client, bufnr)
  lsp.setup(client, bufnr)
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>dm",
    "<cmd>lua require('dap-python').test_method()<cr>",
    { desc = "Dap test method" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "n",
    "<leader>da",
    "<cmd>lua require('dap-python').test_class()<cr>",
    { desc = "Dap test class" }
  )
  lsp.set_buf_keymap(
    bufnr,
    "v",
    "<leader>dv",
    "<cmd>lua require('dap-python').debug_selection()<cr>",
    { desc = "Dap debug selection" }
  )
end

return M
