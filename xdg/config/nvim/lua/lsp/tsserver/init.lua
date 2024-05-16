local M = {}
local vue_language_server_path = os.getenv("VUE_LANGUAGE_SERVER_PATH")

local mason_pkg_path = require("util.lsp").get_mason_pkg_path()
local vue_language_server_mason_path = mason_pkg_path
  .. "/vue-language-server/node_modules/@vue/language-server"
M.init_options = {
  hostInfo = "neovim",
  plugins = {
    {
      name = "@vue/typescript-plugin",
      -- environment variable has highest priority, then relative path, then absolute path
      location = vue_language_server_path
        or vue_language_server_mason_path
        or "node_modules/@vue/language-server"
        or "/usr/local/lib/node_modules/@vue/language-server",
      languages = { "javascript", "typescript", "vue" },
    },
  },
}
M.filetypes = {
  "javascript",
  "javascriptreact",
  "javascript.jsx",
  "typescript",
  "typescriptreact",
  "typescript.tsx",
  "vue",
}
M.settings = {
  format = { enable = false },
}
return {}
