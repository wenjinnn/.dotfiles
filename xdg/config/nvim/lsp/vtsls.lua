local vue_language_server_path = vim.env.VUE_LANGUAGE_SERVER_PATH
vim.lsp.config('vtsls', {
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
})
local vue_plugin = {
  name = '@vue/typescript-plugin',
  location = vue_language_server_path
    or 'node_modules/@vue/language-server'
    or '/usr/local/lib/node_modules/@vue/language-server',
  languages = { 'vue' },
  configNamespace = 'typescript',
}
return {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          vue_plugin,
        },
      },
    },
  },
}
