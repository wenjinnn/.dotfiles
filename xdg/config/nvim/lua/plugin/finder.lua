local in_vscode = require("util").in_vscode
local map = vim.keymap.set
if in_vscode() then
  return
end
local now, later = MiniDeps.now, MiniDeps.later

now(function()
  require("mini.files").setup({
    windows = {
      preview = true,
      width_preview = 40,
    },
  })
  map("n", "<leader>fe", function()
    MiniFiles.open()
  end, { desc = "MiniFiles open" })
  map("n", "<leader>fE",
    function()
      if vim.fn.filereadable(vim.fn.bufname("%")) > 0 then
        MiniFiles.open(vim.api.nvim_buf_get_name(0))
      else
        MiniFiles.open()
      end
    end,
    { desc = "MiniFiles open current" })
end)

later(function()
  require("mini.visits").setup()
  map("n", "<leader>v", function()
    MiniVisits.add_label()
  end, { desc = "MiniVisits add label" })
  map("n", "<leader>V", function()
    MiniVisits.remove_label()
  end, { desc = "MiniVisits remove label" })
end)

later(function()
  require("mini.pick").setup()
  vim.ui.select = MiniPick.ui_select
  local show_with_icons = function(buf_id, items, query)
    return MiniPick.default_show(buf_id, items, query, { show_icons = true })
  end
  -- pick grep function that pass args to rg
  MiniPick.registry.grep_args = function()
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

    return MiniPick.builtin.cli(
      { command = command },
      { source = { name = string.format("Grep (rg %s)", args), show = show_with_icons } }
    )
  end
  local function get_terminal_items(local_opts)
    local cmd_opts = local_opts or {}
    local buffers_output = vim.api.nvim_exec2("buffers" .. (cmd_opts.include_unlisted and "!" or "") .. " R",
      { output = true })
    local items = {}
    if buffers_output.output ~= "" then
      for _, l in ipairs(vim.split(buffers_output.output, "\n")) do
        local buf_str, name = l:match("^%s*%d+"), l:match('"(.*)"')
        local buf_id = tonumber(buf_str)
        local item = { text = name, bufnr = buf_id }
        table.insert(items, item)
      end
    end
    return items
  end
  -- select terminals
  MiniPick.registry.terminals = function(local_opts)
    local items = get_terminal_items(local_opts)
    local terminal_opts = { source = { name = "Terminal buffers", show = show_with_icons, items = items } }
    return MiniPick.start(terminal_opts)
  end
  vim.api.nvim_create_user_command("PickOrNewTerminal",
    function()
      local items = get_terminal_items()
      if #items == 0 then
        vim.cmd("terminal")
      elseif #items == 1 then
        vim.cmd("buffer " .. items[1].bufnr)
      else
        vim.cmd("Pick terminals")
      end
    end
    , { desc = "Format changed lines" })
  map("n", "<leader>ft", "<cmd>PickOrNewTerminal<cr>", { desc = "Pick terminals or new one" })
  map("n", "<leader>fG", "<cmd>Pick grep_args<cr>", { desc = "Pick grep with rg args" })
  map("n", "<leader>ff", "<cmd>Pick files<cr>", { desc = "Pick files" })
  map("n", "<leader>fg", "<cmd>Pick grep_live<cr>", { desc = "Pick grep live" })
  map("n", "<leader>fH", "<cmd>Pick help<cr>", { desc = "Pick help" })
  map("n", "<leader>fb", "<cmd>Pick buffers<cr>", { desc = "Pick buffers" })
  map("n", "<leader>fc", "<cmd>Pick cli<cr>", { desc = "Pick cli" })
  map("n", "<leader>fR", "<cmd>Pick resume<cr>", { desc = "Pick resume" })
  map("n", "<leader>fd", "<cmd>Pick diagnostic scope='current'<cr>", { desc = "Pick current diagnostic" })
  map("n", "<leader>fD", "<cmd>Pick diagnostic scope='all'<cr>", { desc = "Pick all diagnostic" })
  map("n", "<leader>gb", "<cmd>Pick git_branches<cr>", { desc = "Pick git branches" })
  map("n", "<leader>gC", "<cmd>Pick git_commits<cr>", { desc = "Pick git commits" })
  map("n", "<leader>gc", "<cmd>Pick git_commits path='%'<cr>", { desc = "Pick git commits current" })
  map("n", "<leader>gf", "<cmd>Pick git_files<cr>", { desc = "Pick git files" })
  map("n", "<leader>gH", "<cmd>Pick git_hunks<cr>", { desc = "Pick git hunks" })
  map("n", "<leader>fP", "<cmd>Pick hipatterns<cr>", { desc = "Pick hipatterns" })
  map("n", "<leader>fh", "<cmd>Pick history<cr>", { desc = "Pick history" })
  map("n", "<leader>fL", "<cmd>Pick hl_groups<cr>", { desc = "Pick hl groups" })
  map("n", "<leader>fk", "<cmd>Pick keymaps<cr>", { desc = "Pick keymaps" })
  map("n", "<leader>fl", "<cmd>Pick list scope='location'<cr>", { desc = "Pick location" })
  map("n", "<leader>fj", "<cmd>Pick list scope='jump'<cr>", { desc = "Pick jump" })
  map("n", "<leader>fq", "<cmd>Pick list scope='quickfix'<cr>", { desc = "Pick quickfix" })
  map("n", "<leader>fC", "<cmd>Pick list scope='change'<cr>", { desc = "Pick change" })
  map("n", "<leader>fm", "<cmd>Pick marks<cr>", { desc = "Pick marks" })
  map("n", "<leader>fo", "<cmd>Pick oldfiles<cr>", { desc = "Pick oldfiles" })
  map("n", "<leader>fO", "<cmd>Pick options<cr>", { desc = "Pick options" })
  map("n", "<leader>fr", "<cmd>Pick registers<cr>", { desc = "Pick registers" })
  map("n", "<leader>fp", "<cmd>Pick spellsuggest<cr>", { desc = "Pick spell suggest" })
  map("n", "<leader>fT", "<cmd>Pick treesitter<cr>", { desc = "Pick treesitter" })
  map("n", "<leader>fv", "<cmd>Pick visit_paths<cr>", { desc = "Pick visit paths" })
  map("n", "<leader>fV", "<cmd>Pick visit_labels<cr>", { desc = "Pick visit labels" })
  map("n", "<leader>cd", "<cmd>Pick lsp scope='definition'<CR>", { desc = "Pick lsp definition" })
  map("n", "<leader>cD", "<cmd>Pick lsp scope='declaration'<CR>", { desc = "Pick lsp declaration" })
  map("n", "<leader>cr", "<cmd>Pick lsp scope='references'<cr>", { desc = "Pick lsp references" })
  map("n", "<leader>ci", "<cmd>Pick lsp scope='implementation'<CR>", { desc = "Pick lsp implementation" })
  map("n", "<leader>ct", "<cmd>Pick lsp scope='type_definition'<cr>", { desc = "Pick lsp type definition" })
  map("n", "<leader>fs", "<cmd>Pick lsp scope='document_symbol'<cr>", { desc = "Pick lsp document symbol" })
  map("n", "<leader>fS",
    "<cmd>Pick lsp scope='workspace_symbol' symbol_query=vim.fn.input('Symbol:\\ ')<cr>",
    { desc = "Pick lsp workspace symbol" })
end)
