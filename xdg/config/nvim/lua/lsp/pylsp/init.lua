local M = {}
local lsp = require("util.lsp")

function M.on_attach(client, bufnr)
  lsp.setup(client, bufnr)
  local map = lsp.buf_map(bufnr)
  map("<leader>dm", "<cmd>lua require'dap-python'.test_method()<cr>", "Dap test method")
  map("<leader>da", "<cmd>lua require'dap-python'.test_class()<cr>", "Dap test class")
  map("<leader>dv", "<cmd>lua require'dap-python'.debug_selection()<cr>", "Dap debug selection", "v")
end

return M
