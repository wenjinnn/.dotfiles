local hostname = vim.fn.hostname()
local username = os.getenv('USER')
vim.lsp.config('nixd', {
  settings = {
    nixd = {
      formatting = {
        command = { 'nixfmt' },
      },
      options = {
        nixos = {
          expr = string.format(
            '(builtins.getFlake ("git+file://" + toString ./.)).nixosConfigurations.%s.options',
            hostname
          ),
        },
        home_manager = {
          expr = string.format(
            '(builtins.getFlake ("git+file://" + toString ./.)).homeConfigurations."%s@%s".options',
            username,
            hostname
          ),
        },
      },
    },
  },
})
