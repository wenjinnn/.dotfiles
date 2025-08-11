return {
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using
        -- (most likely LuaJIT in the case of Neovim)
        version = 'LuaJIT',
      },
      completion = {
        callSnippet = true,
      },
      signature = {
        detailSignatureHelper = true,
      },
      -- Make the server aware of Neovim runtime files
      workspace = {
        ignoreDir = { 'build', 'dist', 'node_modules', '.git' },
        ignoreGlobs = { '*.log' },
        library = vim.api.nvim_get_runtime_file('', true),
      },
    },
  },
}
