local M = {}

function M.set_keymap(bufnr, ...)
  vim.api.nvim_buf_set_keymap(bufnr, ...)
end

function M.set_option(bufnr, ...)
  vim.api.nvim_buf_set_option(bufnr, ...)
end

local opts = { noremap = true, silent = true }
M.opts = opts

function M.setup(client, bufnr)
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_create_augroup("lsp_document_highlight", {
      clear = false,
    })
    vim.api.nvim_clear_autocmds({
      buffer = bufnr,
      group = "lsp_document_highlight",
    })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = "lsp_document_highlight",
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
end

function M.make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
  return capabilities
end

return M
