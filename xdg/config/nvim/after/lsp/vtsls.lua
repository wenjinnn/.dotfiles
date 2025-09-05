local local_vue_ls_path = 'node_modules/@vue/language-server'
return {
  settings = {
    vtsls = {
      tsserver = {
        globalPlugins = {
          {
            name = '@vue/typescript-plugin',
            location = vim.fn.isdirectory(local_vue_ls_path) == 1 and local_vue_ls_path
              or vim.env.VUE_LANGUAGE_SERVER_PATH,
            languages = { 'vue' },
            configNamespace = 'typescript',
          },
        },
      },
    },
  },
  filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue' },
}
