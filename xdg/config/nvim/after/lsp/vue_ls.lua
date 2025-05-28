return {
  init_options = {
    typescript = {
      tsdk = os.getenv('TYPESCRIPT_LIBRARY') or 'node_modules/typescript/lib',
    },
  },
  settings = {
    -- let eslint take over format capability
    format = { enable = false },
  },
}
