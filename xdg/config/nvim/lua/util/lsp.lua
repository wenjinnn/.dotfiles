local M = {}
function M.set_keymap(bufnr, mode, lhs, rhs, opts)
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
    vim.lsp.codelens.refresh({ bufnr = bufnr })
    vim.api.nvim_create_autocmd({ "BufEnter", "InsertLeave" }, {
      buffer = bufnr,
      callback = function()
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end,
    })
  end
  M.setup_buf_map(bufnr)
end

function M.make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
  return capabilities
end

function M.get_mason_path()
  local mason_path = os.getenv("MASON")
  if mason_path ~= nil then
    return mason_path
  end
  return vim.fn.stdpath("data") .. "/mason"
end

function M.get_mason_pkg_path()
  local mason_path = os.getenv("MASON")
  return mason_path .. "/packages"
end

function M.setup_buf_map(bufnr)
  local map = M.set_keymap
  map(bufnr, "n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>", { desc = "Lsp hover" })
  map(bufnr, "n", "gD", "<cmd>Pick lsp scope='declaration'<CR>", { desc = "Lsp declaration" })
  map(bufnr, "n", "gd", "<cmd>Pick lsp scope='definition'<CR>", { desc = "Pick lsp definition" })
  map(
    bufnr,
    "n",
    "gt",
    "<cmd>Pick lsp scope='type_definition'<CR>",
    { desc = "Pick lsp type definition" }
  )
  map(
    bufnr,
    "n",
    "gi",
    "<cmd>Pick lsp scope='implementation'<CR>",
    { desc = "Pick lsp implementation" }
  )
  map(
    bufnr,
    "n",
    "gI",
    "<cmd>lua vim.lsp.buf.incoming_calls()<CR>",
    { desc = "Lsp incoming calls" }
  )
  map(
    bufnr,
    "n",
    "gR",
    "<cmd>lua vim.lsp.buf.outgoing_calls()<CR>",
    { desc = "Lsp outgoing calls" }
  )
  map(bufnr, "n", "gr", "<cmd>Pick lsp scope='references'<CR>", { desc = "Pick lsp references" })
end

return M
