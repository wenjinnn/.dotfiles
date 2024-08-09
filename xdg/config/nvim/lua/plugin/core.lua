return {
  -- base plugin
  { "nvim-lua/plenary.nvim", lazy = true },
  { "tpope/vim-repeat", event = "BufRead", lazy = true },
  {
    "echasnovski/mini.basics",
    event = "VeryLazy",
    lazy = true,
    opts = {
      basic = true,
      extra_ui = true,
      mappings = {
        windows = false,
      },
    },
  },
  { "MunifTanjim/nui.nvim", lazy = true },
  {
    "echasnovski/mini.misc",
    event = "VeryLazy",
    lazy = true,
    keys = {
      { "<leader>z", "<cmd>lua MiniMisc.zoom()<cr>", desc = "Zoom current window" },
    },
    config = function()
      require("mini.misc").setup()
      MiniMisc.setup_auto_root()
      MiniMisc.setup_termbg_sync()
      MiniMisc.setup_restore_cursor()

      local use_nested_comments = function() MiniMisc.use_nested_comments() end
      vim.api.nvim_create_autocmd("BufEnter", { callback = use_nested_comments })
    end,
  },
}
