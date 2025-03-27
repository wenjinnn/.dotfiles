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
  if client.server_capabilities.documentHighlightProvider then
    local lsp_document_highlight = require("util").augroup("lsp_document_highlight", { clear = false })
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
      group = require("util").augroup("lsp_codelens"),
      buffer = bufnr,
      callback = function()
        vim.lsp.codelens.refresh({ bufnr = bufnr })
      end,
    })
  end
  ---Utility for keymap creation.
  ---@param lhs string
  ---@param rhs string|function
  ---@param opts string|table
  ---@param mode? string|string[]
  local function keymap(lhs, rhs, opts, mode)
    opts = type(opts) == "string" and { desc = opts }
        or vim.tbl_extend("error", opts --[[@as table]], { buffer = bufnr })
    mode = mode or "n"
    vim.keymap.set(mode, lhs, rhs, opts)
  end

  ---For replacing certain <C-x>... keymaps.
  ---@param keys string
  local function feedkeys(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", true)
  end

  ---Is the completion menu open?
  local function pumvisible()
    return tonumber(vim.fn.pumvisible()) ~= 0
  end

  -- Enable completion and configure keybindings.
  if client.supports_method("textDocument/completion") then
    vim.lsp.completion.enable(true, client.id, bufnr, { autotrigger = true })

    -- Use enter to accept completions.
    keymap("<cr>", function()
      return pumvisible() and "<C-y>" or "<cr>"
    end, { expr = true }, "i")

    -- Use slash to dismiss the completion menu.
    keymap("/", function()
      return pumvisible() and "<C-e>" or "/"
    end, { expr = true }, "i")

    -- Use <C-n> to navigate to the next completion or:
    -- - Trigger LSP completion.
    -- - If there's no one, fallback to vanilla omnifunc.
    keymap("<C-n>", function()
      if pumvisible() then
        feedkeys "<C-n>"
      else
        if next(vim.lsp.get_clients { bufnr = 0 }) then
          vim.lsp.completion.get()
        end
      end
    end, "Trigger/select next completion", "i")

    -- Use <Tab> to accept a Copilot suggestion, navigate between snippet tabstops,
    -- or select the next completion.
    -- Do something similar with <S-Tab>.
    keymap("<Tab>", function()
      if pumvisible() then
        feedkeys "<C-n>"
      elseif vim.snippet.active { direction = 1 } then
        vim.snippet.jump(1)
      else
        feedkeys "<Tab>"
      end
    end, {}, { "i", "s" })
    keymap("<S-Tab>", function()
      if pumvisible() then
        feedkeys "<C-p>"
      elseif vim.snippet.active { direction = -1 } then
        vim.snippet.jump(-1)
      else
        feedkeys "<S-Tab>"
      end
    end, {}, { "i", "s" })

    -- Inside a snippet, use backspace to remove the placeholder.
    keymap("<BS>", "<C-o>s", {}, "s")
  end
  vim.api.nvim_create_autocmd("CompleteChanged", {
    buffer = bufnr,
    callback = function()
      local info = vim.fn.complete_info({ "selected" })
      local completion_item = vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "completion_item")
      if nil == completion_item then
        return
      end
      local resolved_item = vim.lsp.buf_request_sync(
        bufnr,
        vim.lsp.protocol.Methods.completionItem_resolve,
        completion_item,
        500
      )

      if resolved_item == nil then
        return
      end

      local docs = vim.tbl_get(resolved_item[client.id], "result", "documentation", "value")
      if nil == docs then
        return
      end

      local win_data = vim.api.nvim__complete_set(info["selected"], { info = docs })
      if not win_data.winid or not vim.api.nvim_win_is_valid(win_data.winid) then
        return
      end

      vim.treesitter.start(win_data.bufnr, "markdown")
      vim.wo[win_data.winid].conceallevel = 3
      vim.api.nvim_create_autocmd({ "TextChangedI" }, {
        buffer = bufnr,
        callback = function()
          vim.lsp.completion.get()
        end,
      })
    end,
  })
end

function M.make_capabilities()
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.resolveSupport.properties = {
    "edit",
    "documentation",
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

return M
