local M = {}
function M.set_buf_keymap(bufnr, mode, lhs, rhs, opts)
  opts = M.make_opts(opts)
  vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, opts)
end

M.opts = { noremap = true, silent = true }

function M.make_opts(opts)
  return vim.tbl_extend("keep", opts, M.opts)
end

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
  -- inlay hint
  if client.supports_method("textDocument/inlayHint", { bufnr = bufnr }) then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
  -- code lens
  if client.supports_method("textDocument/codeLens", { bufnr = bufnr }) then
    vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave", "CursorHold" }, {
      buffer = bufnr,
      callback = function()
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end,
    })
  end
end

function M.make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
  return capabilities
end

function M.make_lspconfig(opts)
  local config = {
    capabilities = M.make_capabilities(),
    inlay_hints = { enabled = true },
    codelens = { enabled = true },
    document_highlight = { enabled = true },
    on_attach = function(client, bufnr)
      M.setup(client, bufnr)
    end,
  }
  if type(opts) == "table" then
    config = vim.tbl_deep_extend("force", config, opts)
  end
  return config
end

return M
