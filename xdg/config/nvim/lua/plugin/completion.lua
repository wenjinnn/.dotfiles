local not_vscode = require("util").not_vscode

return {
  "hrsh7th/nvim-cmp",
  cond = not_vscode,
  event = { "InsertEnter", "CmdLineEnter" },
  dependencies = {
    { "rafamadriz/friendly-snippets" },
    { "garymjr/nvim-snippets", opts = { friendly_snippets = true } },
    { "hrsh7th/cmp-buffer" },
    { "hrsh7th/cmp-nvim-lsp" },
    { "hrsh7th/cmp-path" },
    { "hrsh7th/cmp-cmdline" },
    { "hrsh7th/cmp-nvim-lsp-signature-help" },
    { "octaltree/cmp-look" },
    { "petertriho/cmp-git" },
    { "rcarriga/cmp-dap" },
    { "kristijanhusak/vim-dadbod-completion" },
  },
  config = function()
    local cmp = require("cmp")
    local lspkind = require("lspkind")
    local util = require("util")
    local feedkey = function(key, mode)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
    end
    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0
        and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s")
          == nil
    end

    local snippets_source_config = {
      name = "snippets",
      max_item_count = 10,
    }

    local cmp_buffer_source_config = {
      name = "buffer",
      max_item_count = 10,
      option = {
        get_bufnrs = function()
          return vim.api.nvim_list_bufs()
        end,
      },
    }
    local cmp_look_source_config = {
      name = "look",
      max_item_count = 5,
      keyword_length = 2,
      option = {
        convert_case = true,
        loud = true,
      },
    }
    local vim_dadbod_completion_config = { name = "vim-dadbod-completion" }

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
      ["<C-e>"] = cmp.mapping(function()
        cmp.mapping.abort()
        if vim.snippet.active() then
          vim.snippet.stop()
        end
      end, { "i", "s" }),
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
        snippets_source_config,
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "git" },
        { name = "orgmode" },
        cmp_buffer_source_config,
        { name = "path" },
        cmp_look_source_config,
      },
      formatting = {
        expandable_indicator = false,
        deprecated = true,
        fields = { "abbr", "menu", "kind" },
        format = function(entry, vim_item)
          local item_source = {
            buffer = "buf",
            nvim_lsp = "lsp",
            snippets = "snip",
            nvim_lsp_signature_help = "sign",
            path = "path",
            cmp_tabnine = "tabnine",
            look = "look",
            cmdline = "cmd",
            treesitter = "treesitter",
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
          local lspkind_format = lspkind.cmp_format({
            mode = "symbol", -- show only symbol annotations
            maxwidth = item_maxwidth, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
            ellipsis_char = ellipsis_char, -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)

            -- The function below will be called before any actual modifications from lspkind
            -- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
            before = function(entry, inner_item)
              local menu = inner_item.menu
              if menu ~= nil and menu:len() > item_maxwidth then
                menu = menu:sub(0, item_maxwidth) .. ellipsis_char
                inner_item.menu = menu
              end
              return inner_item
            end,
          })
          local final_item = lspkind_format(entry, vim_item)
          local source = (item_source)[entry.source.name]
          if source ~= nil then
            final_item.kind = final_item.kind .. " " .. source .. " "
          end
          return final_item
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
        cmp_buffer_source_config,
      },
    })
    cmp.setup.filetype({ "sql", "mysql", "plsql" }, {
      sources = {
        snippets_source_config,
        vim_dadbod_completion_config,
        cmp_buffer_source_config,
        cmp_look_source_config,
      },
    })
    require("cmp_git").setup()
  end,
}
