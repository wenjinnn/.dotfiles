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
    event = "BufReadPre",
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
      local show_with_icons = function(buf_id, items, query)
        return pick.default_show(buf_id, items, query, { show_icons = true })
      end
      -- pick grep function that pass args to rg
      pick.registry.grep_args = function()
        local args = vim.fn.input("Ripgrep args: ")
        local command = {
          "rg",
          "--column",
          "--line-number",
          "--no-heading",
          "--field-match-separator=\\0",
          "--no-follow",
          "--color=never",
        }
        local args_table = vim.fn.split(args, " ")
        vim.list_extend(command, args_table)

        return pick.builtin.cli(
          { command = command },
          { source = { name = string.format("Grep (rg %s)", args), show = show_with_icons } }
        )
      end
      -- -- select terminals
      pick.registry.terminals = function(local_opts)
        local buffers_output = vim.api.nvim_exec2("buffers" .. (local_opts.include_unlisted and "!" or "") .. " R",
          { output = true })
        local items = {}
        for _, l in ipairs(vim.split(buffers_output.output, '\n')) do
          local buf_str, name = l:match('^%s*%d+'), l:match('"(.*)"')
          local buf_id = tonumber(buf_str)
          local item = { text = name, bufnr = buf_id }
          table.insert(items, item)
        end

        local opts = { source = { name = 'Terminal buffers', show = show_with_icons, items = items } }
        return MiniPick.start(opts)
      end
    end,
    keys = {
      { "<leader>ft", "<cmd>Pick terminals<cr>", desc = "Pick terminals" },
      { "<leader>fG", "<cmd>Pick grep_args<cr>", desc = "Pick grep with rg args" },
      { "<leader>ff", "<cmd>Pick files<cr>", desc = "Pick files" },
      { "<leader>fg", "<cmd>Pick grep_live<cr>", desc = "Pick grep live" },
      { "<leader>fH", "<cmd>Pick help<cr>", desc = "Pick help" },
      { "<leader>fb", "<cmd>Pick buffers<cr>", desc = "Pick buffers" },
      { "<leader>fc", "<cmd>Pick cli<cr>", desc = "Pick cli" },
      { "<leader>fR", "<cmd>Pick resume<cr>", desc = "Pick resume" },
      {
        "<leader>fd",
        "<cmd>Pick diagnostic scope='current'<cr>",
        desc = "Pick current diagnostic",
      },
      { "<leader>fD", "<cmd>Pick diagnostic scope='all'<cr>", desc = "Pick all diagnostic" },
      { "<leader>gb", "<cmd>Pick git_branches<cr>", desc = "Pick git branches" },
      { "<leader>gC", "<cmd>Pick git_commits<cr>", desc = "Pick git commits" },
      { "<leader>gc", "<cmd>Pick git_commits path='%'<cr>", desc = "Pick git commits current" },
      { "<leader>gf", "<cmd>Pick git_files<cr>", desc = "Pick git files" },
      { "<leader>gH", "<cmd>Pick git_hunks<cr>", desc = "Pick git hunks" },
      { "<leader>fP", "<cmd>Pick hipatterns<cr>", desc = "Pick hipatterns" },
      { "<leader>fh", "<cmd>Pick history<cr>", desc = "Pick history" },
      { "<leader>fL", "<cmd>Pick hl_groups<cr>", desc = "Pick hl groups" },
      { "<leader>fk", "<cmd>Pick keymaps<cr>", desc = "Pick keymaps" },
      { "<leader>fl", "<cmd>Pick list scope='location'<cr>", desc = "Pick location" },
      { "<leader>fj", "<cmd>Pick list scope='jump'<cr>", desc = "Pick jump" },
      { "<leader>fq", "<cmd>Pick list scope='quickfix'<cr>", desc = "Pick quickfix" },
      { "<leader>fC", "<cmd>Pick list scope='change'<cr>", desc = "Pick change" },
      {
        "<leader>fs",
        "<cmd>Pick lsp scope='document_symbol'<cr>",
        desc = "Pick lsp document symbol",
      },
      {
        "<leader>fS",
        "<cmd>Pick lsp scope='workspace_symbol' symbol_query=vim.fn.input('Symbol:\\ ')<cr>",
        desc = "Pick lsp workspace symbol",
      },
      { "<leader>fm", "<cmd>Pick marks<cr>", desc = "Pick marks" },
      { "<leader>fo", "<cmd>Pick oldfiles<cr>", desc = "Pick oldfiles" },
      { "<leader>fO", "<cmd>Pick options<cr>", desc = "Pick options" },
      { "<leader>fr", "<cmd>Pick registers<cr>", desc = "Pick registers" },
      { "<leader>fp", "<cmd>Pick spellsuggest<cr>", desc = "Pick spell suggest" },
      { "<leader>fT", "<cmd>Pick treesitter<cr>", desc = "Pick treesitter" },
      { "<leader>fv", "<cmd>Pick visit_paths<cr>", desc = "Pick visit paths" },
      { "<leader>fV", "<cmd>Pick visit_labels<cr>", desc = "Pick visit labels" },
      { "<leader>cd", "<cmd>Pick lsp scope='definition'<CR>", desc = "Pick lsp definition" },
      { "<leader>cD", "<cmd>Pick lsp scope='declaration'<CR>", desc = "Pick lsp declaration" },
      { "<leader>cr", "<cmd>Pick lsp scope='references'<cr>", desc = "Pick lsp references" },
      {
        "<leader>ci",
        "<cmd>Pick lsp scope='implementation'<CR>",
        desc = "Pick lsp implementation",
      },
      {
        "<leader>ct",
        "<cmd>Pick lsp scope='type_definition'<cr>",
        desc = "Pick lsp type definition",
      },
      -- let mini.pick load at mini.sessions mason loaded
      { "<leader>ss", "<cmd>lua MiniSessions.select()<cr>", desc = "Session select" },
      { "<leader>M", "<cmd>Mason<CR>", desc = "Mason" },
    },
  },
}
