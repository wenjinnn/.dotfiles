local M = {}

M.opts = { noremap = true, silent = true }

function M.make_opts(opts) return vim.tbl_extend('keep', opts, M.opts) end

function M.setup(client_id, bufnr)
  local augroup = require('util').augroup
  local client = vim.lsp.get_client_by_id(client_id)
  if not client then return end
  if client.server_capabilities.documentHighlightProvider then
    local lsp_document_highlight = augroup('lsp_document_highlight', { clear = false })
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
  -- TODO change to client:supports_method after nvim 0.12 released
  if client.supports_method('textDocument/inlayHint', { bufnr = bufnr }) then
    vim.lsp.inlay_hint.enable(true, { bufnr = bufnr })
  end
  if vim.fn.has("nvim-0.12") == 1 then
    vim.lsp.document_color.enable(true, bufnr)
  end
  -- code lens
  if client.supports_method('textDocument/codeLens', { bufnr = bufnr }) then
    vim.lsp.codelens.refresh({ bufnr = bufnr })
    vim.api.nvim_create_autocmd({ 'BufEnter', 'InsertLeave' }, {
      group = augroup('lsp_codelens'),
      buffer = bufnr,
      callback = function() vim.lsp.codelens.refresh({ bufnr = bufnr }) end,
    })
  end
end

-- notice lsp when filename changed, modified from folke snacks.nvim
function M.on_rename_file(from, to)
  local changes = {
    files = { {
      oldUri = vim.uri_from_fname(from),
      newUri = vim.uri_from_fname(to),
    } },
  }

  local clients = vim.lsp.get_clients()
  for _, client in ipairs(clients) do
    if client.supports_method('workspace/willRenameFiles') then
      local resp = client.request_sync('workspace/willRenameFiles', changes, 1000, 0)
      if resp and resp.result ~= nil then vim.lsp.util.apply_workspace_edit(resp.result, client.offset_encoding) end
    end
  end

  for _, client in ipairs(clients) do
    if client.supports_method('workspace/didRenameFiles') then client.notify('workspace/didRenameFiles', changes) end
  end
end

function M.get_java_cmd()
  local java_home = os.getenv('JDTLS_JAVA_HOME') or os.getenv('JAVA_21_HOME') or os.getenv('JAVA_HOME')
  return java_home and java_home .. '/bin/java' or 'java'
end

function M.java_cmd_optimize(java_cmd, custom_cmd, prefix)
  prefix = prefix or ''
  local cmd = {
    java_cmd or M.get_java_cmd(),
    -- The following 6 lines is for optimize memory use, see https://github.com/redhat-developer/vscode-java/pull/1262#discussion_r386912240
    prefix .. '-XX:+UseParallelGC',
    prefix .. '-XX:MinHeapFreeRatio=5',
    prefix .. '-XX:MaxHeapFreeRatio=10',
    prefix .. '-XX:GCTimeRatio=4',
    prefix .. '-XX:AdaptiveSizePolicyWeight=90',
    prefix .. '-Dsun.zip.disableMemoryMapping=true',
  }
  vim.list_extend(cmd, custom_cmd)
  return cmd
end

return M
