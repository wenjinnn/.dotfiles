vim.lsp.config('eslint', {
  on_attach = function(_, bufnr)
    vim.api.nvim_create_autocmd('BufWritePre', {
      buffer = bufnr,
      command = 'EslintFixAll',
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
