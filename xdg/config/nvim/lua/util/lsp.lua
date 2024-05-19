local M = {}

function M.set_keymap(bufnr, ...)
  vim.api.nvim_buf_set_keymap(bufnr, ...)
end

local opts = { noremap = true, silent = true }
M.opts = opts

function M.make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
  return capabilities
end

function M.get_mason_pkg_path()
  local mason_path = os.getenv("MASON")
  if mason_path ~= nil then
    return mason_path .. "/packages"
  end
  return vim.fn.stdpath("data") .. "/mason/packages"
end

return M
