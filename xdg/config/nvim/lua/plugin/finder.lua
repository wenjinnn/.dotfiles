local not_vscode = require("util").not_vscode
return {
  {
    "echasnovski/mini.files",
    cond = not_vscode,
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
    lazy = true,
    keys = {
      { "<leader>fe", "<cmd>:lua MiniFiles.open()<cr>", desc = "MiniFiles open" },
      {
        "<leader>fE",
        function()
          if vim.fn.filereadable(vim.fn.bufname("%")) > 0 then
            MiniFiles.open(vim.api.nvim_buf_get_name(0))
          else
            MiniFiles.open()
          end
        end,
        desc = "MiniFiles open current",
      },
    },
    opts = {
      windows = {
        preview = true,
        width_preview = 40,
      },
    },
  },
  {
    "echasnovski/mini.visits",
    lazy = true,
    opts = {},
    keys = {
      { "<leader>a", "<cmd>lua MiniVisits.add_label()<cr>", desc = "MiniVisits add label" },
      { "<leader>A", "<cmd>lua MiniVisits.remove_label()<cr>", desc = "MiniVisits remove label" },
    },
  },
  {
    "echasnovski/mini.pick",
    opts = {},
    lazy = true,
    event = "BufRead",
    config = function(_, opts)
      local pick = require("mini.pick")
      pick.setup(opts)
      vim.ui.select = pick.ui_select
    end,
    keys = {
      { "<leader>ff", "<cmd>Pick files<cr>", desc = "Pick files" },
      { "<leader>fg", "<cmd>Pick grep_live<cr>", desc = "Pick grep live" },
      { "<leader>fH", "<cmd>Pick help<cr>", desc = "Pick help" },
      { "<leader>fb", "<cmd>Pick buffers<cr>", desc = "Pick buffers" },
      { "<leader>fc", "<cmd>Pick cli<cr>", desc = "Pick cli" },
      { "<leader>fr", "<cmd>Pick resume<cr>", desc = "Pick resume" },
      { "<leader>fd", "<cmd>Pick diagnostic<cr>", desc = "Pick diagnostic" },
      { "<leader>gb", "<cmd>Pick git_branches<cr>", desc = "Pick git branches" },
      { "<leader>gC", "<cmd>Pick git_commits<cr>", desc = "Pick git commits" },
      { "<leader>gc", "<cmd>Pick git_commits path='%'<cr>", desc = "Pick git commits current" },
      { "<leader>gf", "<cmd>Pick git_files<cr>", desc = "Pick git files" },
      { "<leader>gH", "<cmd>Pick git_hunks<cr>", desc = "Pick git hunks" },
      { "<leader>fp", "<cmd>Pick git_hunks<cr>", desc = "Pick hipatterns" },
      { "<leader>fh", "<cmd>Pick history<cr>", desc = "Pick history" },
      { "<leader>fL", "<cmd>Pick hl_groups<cr>", desc = "Pick hl groups" },
      { "<leader>fk", "<cmd>Pick keymaps<cr>", desc = "Pick keymaps" },
      { "<leader>fl", "<cmd>Pick list<cr>", desc = "Pick list" },
      {
        "<leader>fs",
        "<cmd>Pick lsp scope='document_symbol'<cr>",
        desc = "Pick lsp document symbol",
      },
      {
        "<leader>fS",
        "<cmd>Pick lsp scope='workspace_symbol'<cr>",
        desc = "Pick lsp workspace symbol",
      },
      { "<leader>fm", "<cmd>Pick marks<cr>", desc = "Pick marks" },
      { "<leader>fo", "<cmd>Pick oldfiles<cr>", desc = "Pick oldfiles" },
      { "<leader>fO", "<cmd>Pick options<cr>", desc = "Pick options" },
      { "<leader>fr", "<cmd>Pick registers<cr>", desc = "Pick registers" },
      { "<leader>fp", "<cmd>Pick spell_suggest<cr>", desc = "Pick spell suggest" },
      { "<leader>ft", "<cmd>Pick treesitter<cr>", desc = "Pick treesitter" },
      { "<leader>fv", "<cmd>Pick visit_paths<cr>", desc = "Pick visit paths" },
      { "<leader>fV", "<cmd>Pick visit_labels<cr>", desc = "Pick visit labels" },
      -- let mini.pick load at mini.sessions mason loaded
      { "<leader>ss", "<cmd>lua MiniSessions.select()<cr>", desc = "Session select" },
      { "<leader>M", "<cmd>Mason<CR>", desc = "Mason" },
    },
  },
}
