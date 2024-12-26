local M = {}

function M.buf_map(bufnr)
  return function(lhs, rhs, desc, mode)
    local final_mode = mode or "n";
    local opts = M.make_opts({ desc = desc })
    vim.api.nvim_buf_set_keymap(bufnr, final_mode, lhs, rhs, opts)
  end
end

M.opts = { noremap = true, silent = true }

function M.make_opts(opts)
  return vim.tbl_extend("keep", opts, M.opts)
end

function M.setup(client, bufnr)
  local augroup = require("util").augroup
  if client.server_capabilities.documentHighlightProvider then
    local lsp_document_highlight = augroup("lsp_document_highlight", { clear = false })
    vim.api.nvim_clear_autocmds({
      buffer = bufnr,
      group = lsp_document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
      group = lsp_document_highlight,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
      group = lsp_document_highlight,
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
    vim.lsp.codelens.refresh({ bufnr = bufnr })
    vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
      group = augroup("lsp_codelens"),
      buffer = bufnr,
      callback = function()
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end,
    })
  end
end

function M.make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation" },
  }
  return capabilities
end

function M.make_lspconfig(opts)
  local config = {
    capabilities = M.make_capabilities(),
    on_attach = function(client, bufnr)
      M.setup(client, bufnr)
    end,
  }
  if type(opts) == "table" then
    config = vim.tbl_deep_extend("force", config, opts)
  end
  return config
end

-- notice lsp when filename changed, modified from folke snacks.nvim
function M.on_rename_file(from, to)
  local changes = {
    files = { {
      oldUri = vim.uri_from_fname(from),
      newUri = vim.uri_from_fname(to),
    } }
  }

  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method("workspace/willRenameFiles") then
      local resp = client.request_sync("workspace/willRenameFiles", changes, 1000, 0)
      if resp and resp.result ~= nil then
        vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding)
      end
    end
  end

  for _, client in ipairs(clients) do
    if client.supports_method("workspace/didRenameFiles") then
      client.notify("workspace/didRenameFiles", changes)
    end
  end
end

return M
