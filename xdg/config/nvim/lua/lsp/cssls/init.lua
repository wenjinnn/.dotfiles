local capabilities = require('util.lsp').make_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
local M = {
  capabilities = capabilities,
}

return M
