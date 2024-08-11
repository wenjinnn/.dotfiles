local in_vscode = require("util").in_vscode
if in_vscode() then
  return
end
local add, later = MiniDeps.add, MiniDeps.later
later(function()
  add({
    source = "hrsh7th/nvim-cmp",
    depends = {
      "rafamadriz/friendly-snippets",
      "garymjr/nvim-snippets",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp-signature-help",
      "uga-rosa/cmp-dictionary",
      "petertriho/cmp-git",
      "rcarriga/cmp-dap",
      "kristijanhusak/vim-dadbod-completion",
    },
  })
  local cmp = require("cmp")
  local util = require("util")
  local feedkey = util.feedkey
  local has_words_before = function()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0
        and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s")
        == nil
  end
  local snippets_source = {
    name = "snippets",
    max_item_count = 10,
  }
  local cmp_buffer_source = {
    name = "buffer",
    max_item_count = 10,
    option = {
      get_bufnrs = function()
        return vim.api.nvim_list_bufs()
      end,
    },
  }
  local cmp_dict_source = {
    name = "dictionary",
    keyword_length = 2,
    max_item_count = 10,
  }
  local dadbod_source = { name = "vim-dadbod-completion" }

  local item_sources = {
    buffer = "buf",
    nvim_lsp = "lsp",
    snippets = "snip",
    nvim_lsp_signature_help = "sign",
    path = "path",
    cmp_tabnine = "tabnine",
    spell = "spell",
    cmdline = "cmd",
    treesitter = "treesitter",
    dictionary = "dict",
    nvim_lua = "lua",
    latex_symbols = "latex",
    dap = "dap",
    git = "git",
    orgmode = "org",
    ["cmp-dbee"] = "dbee",
    ["vim-dadbod-completion"] = "db",
  }
  local item_maxwidth = 30
  local ellipsis_char = "…"

  local combined_cr_mapping = {
    ["<S-CR>"] = cmp.mapping.confirm({
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    }),
    ["<C-CR>"] = function(fallback)
      cmp.abort()
      fallback()
    end,
  }
  local insert_extra_mapping = {
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(),
    ["<C-e>"] = cmp.mapping.abort(),
    ["<CR>"] = function(fallback)
      if cmp.core.view:visible() or vim.fn.pumvisible() == 1 then
        util.create_undo()
        if cmp.confirm({ select = true }) then
          return
        end
      end
      return fallback()
    end,
    ["<Tab>"] = cmp.mapping(function(fallback)
      if vim.snippet.active({ direction = 1 }) then
        feedkey("<cmd>lua vim.snippet.jump(1)<CR>", "")
      elseif cmp.visible() then
        cmp.select_next_item()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
      end
    end, { "i", "s" }),
    ["<S-Tab>"] = cmp.mapping(function()
      if vim.snippet.active({ direction = -1 }) then
        feedkey("<cmd>lua vim.snippet.jump(-1)<CR>", "")
      elseif cmp.visible() then
        cmp.select_prev_item()
      end
    end, { "i", "s" }),
  }

  for key, value in pairs(combined_cr_mapping) do
    insert_extra_mapping[key] = value
  end

  cmp.setup({
    window = {
      documentation = {
        max_width = 70,
      },
    },
    experimental = {
      ghost_text = true,
    },
    snippet = {
      expand = function(args)
        vim.snippet.expand(args.body)
      end,
    },
    mapping = cmp.mapping.preset.insert(insert_extra_mapping),
    sources = {
      snippets_source,
      { name = "nvim_lsp" },
      { name = "nvim_lsp_signature_help" },
      { name = "git" },
      { name = "orgmode" },
      cmp_buffer_source,
      { name = "path" },
      cmp_dict_source,
    },
    formatting = {
      expandable_indicator = false,
      deprecated = true,
      fields = { "abbr", "menu", "kind" },
      format = function(entry, vim_item)
        --- limit vim_item sub attribute width
        ---@param item string
        ---@return string limited string
        local function limit_width(item)
          if item ~= nil and item:len() > item_maxwidth then
            item = item:sub(0, item_maxwidth) .. ellipsis_char
            return item
          end
          return item
        end
        local icon, hl = require("mini.icons").get("lsp", vim_item.kind)
        if icon ~= nil then
          vim_item.kind = icon
          vim_item.kind_hl_group = hl
        end
        vim_item.menu = limit_width(vim_item.menu)
        vim_item.abbr = limit_width(vim_item.abbr)
        local source = (item_sources)[entry.source.name]
        if source ~= nil then
          vim_item.kind = vim_item.kind .. " " .. source .. " "
        end
        return vim_item
      end,
    },
  })
  -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
  cmp.setup.cmdline(":", {
    mapping = cmp.mapping.preset.cmdline(combined_cr_mapping),
    sources = cmp.config.sources({
      { name = "path" },
    }, {
      { name = "cmdline" },
    }),
  })
  cmp.setup.cmdline({ "/", "?" }, {
    mapping = cmp.mapping.preset.cmdline(combined_cr_mapping),
    sources = cmp.config.sources({
      { name = "buffer" },
    }),
  })
  cmp.setup.filetype({ "dap-repl" }, {
    enabled = function()
      return vim.api.nvim_get_option_value("buftype", { buf = 0 }) ~= "prompt"
          or require("cmp_dap").is_dap_buffer()
    end,
    sources = {
      { name = "dap", keyword_length = 1 },
      cmp_buffer_source,
    },
  })
  cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
    sources = {
      snippets_source,
      dadbod_source,
      cmp_buffer_source,
      cmp_dict_source,
    },
  })
  require("cmp_git").setup()
  require("cmp_dictionary").setup({
    paths = { os.getenv("WORDLIST") or "/usr/share/dict/words" },
    external = {
      enable = true,
      command = { "look", "${prefix}", "${path}" },
    },
    first_case_insensitive = true,
    document = {
      enable = true,
      command = { "wn", "${label}", "-over" },
    },
  })
  require("snippets").setup({ friendly_snippets = true })
end)
