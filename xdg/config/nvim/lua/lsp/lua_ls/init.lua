local M = {}
M.on_init = function(client)
  local path = client.workspace_folders[1].name
  if vim.loop.fs_stat(path .. '/.luarc.json') or vim.loop.fs_stat(path .. '/.luarc.jsonc') then return end

  client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
    runtime = {
      -- Tell the language server which version of Lua you're using
      -- (most likely LuaJIT in the case of Neovim)
      version = 'LuaJIT',
    },
    -- Make the server aware of Neovim runtime files
    workspace = {
      checkThirdParty = false,
      library = {
        vim.env.VIMRUNTIME,
        -- Depending on the usage, you might want to add additional paths here.
        -- "${3rd}/luv/library"
        -- "${3rd}/busted/library",
      },
      -- or pull in all of 'runtimepath'. NOTE: this is a lot slower
      -- library = vim.api.nvim_get_runtime_file("", true)
    },
    hint = {
      enable = true,
    },
    codeLens = {
      enable = true,
    },
    format = {
      enable = true,
      defaultConfig = {
        indent_size = '2',
        quote_style = 'double',
        trailing_table_separator = 'smart',
        align_call_args = 'false',
        align_function_params = 'false',
        align_continuous_assign_statement = 'false',
        align_continuous_rect_table_field = 'false',
        align_if_branch = 'false',
        align_array_table = 'false',
        align_continuous_similar_call_args = 'false',
        align_continuous_inline_comment = 'false',
        align_chain_expr = 'none',
      },
    },
  })
end
M.settings = {
  Lua = {},
}
return M
