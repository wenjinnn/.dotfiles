local M = {}
local lsp = require("util.lsp")

function M.on_attach(client, bufnr)
  lsp.setup(client, bufnr)
  local map = lsp.buf_map(bufnr)
  local dap_python = require("dap-python")
  map("n", "<leader>dm", dap_python.test_method, "Dap test method")
  map("n", "<leader>da", dap_python.test_class, "Dap test class")
  map("v", "<leader>dv", dap_python.debug_selection, "Dap debug selection")
end

return M
