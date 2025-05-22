local capabilities = require('util.lsp').make_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true
vim.lsp.config('cssls', {
  {
    capabilities = capabilities,
  },
})
