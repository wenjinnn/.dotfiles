local vue_language_server_path = vim.env.VUE_LANGUAGE_SERVER_PATH
return {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = vue_language_server_path
              or 'node_modules/@vue/language-server'
              or '/usr/local/lib/node_modules/@vue/language-server',
            languages = { 'vue' },
            configNamespace = 'typescript',
          },
        },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
}
