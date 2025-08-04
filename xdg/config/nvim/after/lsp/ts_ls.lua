local vue_language_server_path = os.getenv('VUE_LANGUAGE_SERVER_PATH')
local inlay_hints_settings = {
  includeInlayEnumMemberValueHints = true,
  includeInlayFunctionLikeReturnTypeHints = true,
  includeInlayFunctionParameterTypeHints = true,
  includeInlayParameterNameHints = 'literal',
  includeInlayParameterNameHintsWhenArgumentMatchesName = false,
  includeInlayPropertyDeclarationTypeHints = true,
  includeInlayVariableTypeHints = false,
  includeInlayVariableTypeHintsWhenTypeMatchesName = false,
}
return {
  init_options = {
    plugins = {
      {
        name = '@vue/typescript-plugin',
        -- environment variable has highest priority, then relative path, then absolute path
        location = vue_language_server_path
          or 'node_modules/@vue/language-server'
          or '/usr/local/lib/node_modules/@vue/language-server',
        languages = { 'javascript', 'typescript', 'vue' },
      },
    },
  },
  filetypes = {
    'javascript',
    'javascriptreact',
    'javascript.jsx',
    'typescript',
    'typescriptreact',
    'typescript.tsx',
    'vue',
  },
  settings = {
    typescript = {
      inlayHints = inlay_hints_settings,
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
    },
    javascript = {
      inlayHints = inlay_hints_settings,
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
    },
  },
}
