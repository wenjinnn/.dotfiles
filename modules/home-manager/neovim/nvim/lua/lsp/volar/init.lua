local M = {}
M.init_options = {
  typescript = {
    tsdk = os.getenv("TYPESCRIPT_LIBRARY") or "node_modules/typescript/lib",
  },
}

M.settings = {
  -- let eslint take over format capability
  format = { enable = false },
}
return M
