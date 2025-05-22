-- when using lsp/<lsp_name>.lua with nvim-lspconfig, needs to setup this way to overrides the lspconfig default
vim.lsp.config('vue_ls', {
  init_options = {
    typescript = {
      tsdk = os.getenv('TYPESCRIPT_LIBRARY') or 'node_modules/typescript/lib',
    },
  },
  settings = {
    -- let eslint take over format capability
    format = { enable = false },
  },
})
