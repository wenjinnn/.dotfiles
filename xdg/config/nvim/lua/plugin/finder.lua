if vim.g.vscode then return end

local map = require("util").map
local now, later = MiniDeps.now, MiniDeps.later

-- Load mini.files immediately for sometimes we are gonna open folder with nvim
-- In this case mini.files can't be lazy load
now(function()
  require("mini.files").setup({
    windows = {
      preview = true,
      width_preview = 40,
    },
  })
  -- if current are readable in file system, open mini.files at the current buffer's location.
  local function minifiles_open_current()
    if vim.fn.filereadable(vim.fn.bufname("%")) > 0 then
      MiniFiles.open(vim.api.nvim_buf_get_name(0), false)
    else
      MiniFiles.open(MiniFiles.get_latest_path())
    end
  end
  map("n", "<leader>fe", MiniFiles.open, "MiniFiles open")
  map("n", "<leader>fE", minifiles_open_current, "MiniFiles open current")
  -- send notification to lsp when mini.files rename actions triggered
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesActionRename",
    callback = function(event)
      require("util.lsp").on_rename_file(event.data.from, event.data.to)
    end,
  })
end)

-- visit recent files and we could add labels for files, easy to group files
later(function()
  require("mini.visits").setup()
  map("n", "<leader>v", MiniVisits.add_label, "MiniVisits add label")
  map("n", "<leader>V", MiniVisits.remove_label, "MiniVisits remove label")
end)

-- mini.pick with lot custom keymaps
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
  local function filter_buffers(pattern, cmd_opts)
    cmd_opts = cmd_opts or {}
    local items = {}
    local buffers_output = vim.api.nvim_exec2("filter" .. (cmd_opts.revert and "! " or " ") .. pattern .. " ls",
      { output = true })
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
  local function get_terminal_items(local_opts)
    local dap_terms = filter_buffers("/^\\[dap-terminal\\]/")
    local terms = filter_buffers("/^term:\\/\\//")
    return vim.list_extend(terms, dap_terms)
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
        vim.cmd("startinsert")
      else
        vim.cmd("Pick terminals")
      end
    end
    , { desc = "Pick terminals or new one" })
  map("n", "<leader>ft", "<cmd>PickOrNewTerminal<cr>", "Pick terminals or new one")
  map("n", "<leader>fG", "<cmd>Pick grep_args<cr>", "Pick grep with rg args")
  map("n", "<leader>ff", "<cmd>Pick files<cr>", "Pick files")
  map("n", "<leader>fg", "<cmd>Pick grep_live<cr>", "Pick grep live")
  map("n", "<leader>fH", "<cmd>Pick help<cr>", "Pick help")
  map("n", "<leader>fb", "<cmd>Pick buffers<cr>", "Pick buffers")
  map("n", "<leader>fc", "<cmd>Pick cli<cr>", "Pick cli")
  map("n", "<leader>fR", "<cmd>Pick resume<cr>", "Pick resume")
  map("n", "<leader>fd", "<cmd>Pick diagnostic scope='current'<cr>", "Pick current diagnostic")
  map("n", "<leader>fD", "<cmd>Pick diagnostic scope='all'<cr>", "Pick all diagnostic")
  map("n", "<leader>gb", "<cmd>Pick git_branches<cr>", "Pick git branches")
  map("n", "<leader>gC", "<cmd>Pick git_commits<cr>", "Pick git commits")
  map("n", "<leader>gc", "<cmd>Pick git_commits path='%'<cr>", "Pick git commits current")
  map("n", "<leader>gf", "<cmd>Pick git_files<cr>", "Pick git files")
  map("n", "<leader>gH", "<cmd>Pick git_hunks<cr>", "Pick git hunks")
  map("n", "<leader>fP", "<cmd>Pick hipatterns<cr>", "Pick hipatterns")
  map("n", "<leader>fh", "<cmd>Pick history<cr>", "Pick history")
  map("n", "<leader>fL", "<cmd>Pick hl_groups<cr>", "Pick hl groups")
  map("n", "<leader>fk", "<cmd>Pick keymaps<cr>", "Pick keymaps")
  map("n", "<leader>fl", "<cmd>Pick list scope='location'<cr>", "Pick location")
  map("n", "<leader>fj", "<cmd>Pick list scope='jump'<cr>", "Pick jump")
  map("n", "<leader>fq", "<cmd>Pick list scope='quickfix'<cr>", "Pick quickfix")
  map("n", "<leader>fC", "<cmd>Pick list scope='change'<cr>", "Pick change")
  map("n", "<leader>fm", "<cmd>Pick marks<cr>", "Pick marks")
  map("n", "<leader>fo", "<cmd>Pick oldfiles<cr>", "Pick oldfiles")
  map("n", "<leader>fO", "<cmd>Pick options<cr>", "Pick options")
  map("n", "<leader>fr", "<cmd>Pick registers<cr>", "Pick registers")
  map("n", "<leader>fp", "<cmd>Pick spellsuggest<cr>", "Pick spell suggest")
  map("n", "<leader>fT", "<cmd>Pick treesitter<cr>", "Pick treesitter")
  map("n", "<leader>fv", "<cmd>Pick visit_paths<cr>", "Pick visit paths")
  map("n", "<leader>fV", "<cmd>Pick visit_labels<cr>", "Pick visit labels")
  map("n", "<leader>cd", "<cmd>Pick lsp scope='definition'<CR>", "Pick lsp definition")
  map("n", "<leader>cD", "<cmd>Pick lsp scope='declaration'<CR>", "Pick lsp declaration")
  map("n", "<leader>cr", "<cmd>Pick lsp scope='references'<cr>", "Pick lsp references")
  map("n", "<leader>ci", "<cmd>Pick lsp scope='implementation'<CR>", "Pick lsp implementation")
  map("n", "<leader>ct", "<cmd>Pick lsp scope='type_definition'<cr>", "Pick lsp type definition")
  map("n", "<leader>fs", "<cmd>Pick lsp scope='document_symbol'<cr>", "Pick lsp document symbol")
  map("n", "<leader>fS",
    "<cmd>Pick lsp scope='workspace_symbol' symbol_query=vim.fn.input('Symbol:\\ ')<cr>",
    "Pick lsp workspace symbol")
end)
