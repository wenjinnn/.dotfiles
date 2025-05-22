vim.lsp.config('eslint', {
  on_attach = function(client, bufnr)
    vim.lsp.config.eslint.on_attach(client, bufnr)
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      command = 'LspEslintFixAll',
    })
  end,
  settings = {
    format = { enable = true },
    autoFixOnSave = true,
    codeActionsOnSave = {
      mode = 'all',
      rules = { '!debugger', '!no-only-tests/*' },
    },
    lintTask = {
      enable = true,
    },
  },
})
