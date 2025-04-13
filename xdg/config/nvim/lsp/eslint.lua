local M = {}

function M.on_attach(_, bufnr)
  vim.api.nvim_create_autocmd('BufWritePre', {
    buffer = bufnr,
    command = 'EslintFixAll',
  })
end

M.settings = {
  format = { enable = true },
  autoFixOnSave = true,
  codeActionsOnSave = {
    mode = 'all',
    rules = { '!debugger', '!no-only-tests/*' },
  },
  lintTask = {
    enable = true,
  },
}

return M
