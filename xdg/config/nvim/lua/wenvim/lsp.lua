local M = {}

function M.on_detach(ev)
  local bufnr = ev.buf
  local detach_client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not detach_client then return end
  local clients = vim.lsp.get_clients({ bufnr = bufnr })
  for _, client in ipairs(clients) do
    if client.id ~= detach_client.id and client.server_capabilities.documentHighlightProvider then return end
  end
  vim.lsp.buf.clear_references()
  local lsp_document_highlight = wenvim.util.augroup('lsp_document_highlight', { clear = false })
  vim.api.nvim_clear_autocmds({
    buffer = bufnr,
    group = lsp_document_highlight,
  })
end

function M.on_attach(ev)
  local bufnr = ev.buf
  local client = vim.lsp.get_client_by_id(ev.data.client_id)
  if not client then return end
  if client.server_capabilities.documentHighlightProvider then
    local lsp_document_highlight = wenvim.util.augroup('lsp_document_highlight', { clear = false })
    vim.api.nvim_clear_autocmds({
      buffer = bufnr,
      group = lsp_document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorHold', 'CursorHoldI' }, {
      group = lsp_document_highlight,
      buffer = bufnr,
      callback = vim.lsp.buf.document_highlight,
    })
    vim.api.nvim_create_autocmd({ 'CursorMoved', 'CursorMovedI' }, {
      group = lsp_document_highlight,
      buffer = bufnr,
      callback = vim.lsp.buf.clear_references,
    })
  end
  -- inlay hint
  if client:supports_method('textDocument/inlayHint', bufnr) then vim.lsp.inlay_hint.enable(true, { bufnr = bufnr }) end
  -- code lens
  if client:supports_method('textDocument/codeLens', bufnr) then vim.lsp.codelens.enable(true, { bufnr = bufnr }) end
  -- enable on type formatting
  if client:supports_method('textDocument/onTypeFormatting', bufnr) then
    vim.lsp.on_type_formatting.enable(true, { client_id = client.id })
  end
  -- enable linked editing range
  if client:supports_method('textDocument/linkedEditingRange', bufnr) then
    vim.lsp.linked_editing_range.enable(true, { client_id = client.id })
  end
end

return M
