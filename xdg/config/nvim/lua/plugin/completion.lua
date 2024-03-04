local not_vscode = require("util").not_vscode
-- lsp auto completion & snip
local item_source = {
  buffer = "buf",
  nvim_lsp = "lsp",
  vsnip = "snip",
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
  ["vim-dadbod-completion"] = "dadbod",
}
local item_maxwidth = 50
local ellipsis_char = "…"

return {
  "hrsh7th/nvim-cmp",
  cond = not_vscode,
  module = false,
  event = { "InsertEnter", "CmdLineEnter" },
  dependencies = {
    { "rafamadriz/friendly-snippets" },
    { "hrsh7th/vim-vsnip" },
    { "hrsh7th/vim-vsnip-integ" },
    { "hrsh7th/cmp-vsnip" },
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
    local cmp_buffer = require("cmp_buffer")
    local menu_source_width = 50
    local feedkey = function(key, mode)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(key, true, true, true), mode, true)
    end
    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0
        and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s")
          == nil
    end

    cmp.setup({
      completion = {
        completeopt = "menu,menuone,noinsert,preview",
      },
      view = {
        entries = "custom", -- can be "custom", "wildmenu" or "native"
      },
      window = {
        documentation = {
          max_width = 70,
          winhighlight = "Normal:Pmenu,FloatBorder:Pmenu,CursorLine:PmenuSel,Search:None",
        },
        completion = {
          -- winhighlight = 'Normal:CmpPmenu,FloatBorder:CmpPmenuBorder,CursorLine:PmenuSel,Search:None',
        },
      },
      experimental = {
        ghost_text = true,
      },
      snippet = {
        expand = function(args)
          vim.fn["vsnip#anonymous"](args.body)
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping(
          cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Select }),
          { "i", "c" }
        ),
        ["<C-p>"] = cmp.mapping(
          cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Select }),
          { "i", "c" }
        ),
        ["<C-b>"] = cmp.mapping(cmp.mapping.scroll_docs(-4), { "i", "c" }),
        ["<C-f>"] = cmp.mapping(cmp.mapping.scroll_docs(4), { "i", "c" }),
        ["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
        ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ["<C-e>"] = cmp.mapping({
          i = cmp.mapping.abort(),
          c = cmp.mapping.close(),
        }),
        ["<CR>"] = cmp.mapping({
          i = cmp.mapping.confirm({
            -- behavior = cmp.ConfirmBehavior.Replace,
            select = true,
          }),
          c = cmp.mapping.confirm({ select = true }),
        }),
        ["<Tab>"] = cmp.mapping(function(fallback)
          if cmp.visible() then
            cmp.select_next_item()
          elseif vim.fn["vsnip#available"](1) == 1 then
            feedkey("<Plug>(vsnip-expand-or-jump)", "")
          elseif has_words_before() then
            cmp.complete()
          else
            fallback() -- The fallback function sends a already mapped key. In this case, it's probably `<Tab>`.
          end
        end, { "i", "s" }),
        ["<S-Tab>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item()
          elseif vim.fn["vsnip#jumpable"](-1) == 1 then
            feedkey("<Plug>(vsnip-jump-prev)", "")
          end
        end, { "i", "s" }),
      }),
      sources = {
        {
          name = "vsnip",
          max_item_count = 10,
        },
        { name = "nvim_lsp" },
        { name = "nvim_lsp_signature_help" },
        { name = "git" },
        {
          name = "buffer",
          max_item_count = 10,
          option = {
            get_bufnrs = function()
              return vim.api.nvim_list_bufs()
            end,
          },
        },
        {
          name = "path",
          max_item_count = 10,
        },
        {
          name = "look",
          max_item_count = 5,
          keyword_length = 2,
          option = {
            convert_case = true,
            loud = true,
          },
        },
        { name = "vim-dadbod-completion" },
        { name = "orgmode" },
      },
      formatting = {
        expandable_indicator = false,
        deprecated = true,
        fields = { "abbr", "menu", "kind" },
        format = function(entry, vim_item)
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
      -- sorting = {
      --   comparators = {
      --     function(...) return cmp_buffer:compare_locality(...) end,
      --     -- The rest of your comparators...
      --   }
      -- }
    })
    -- If you want insert `(` after select function or method item
    -- local cmp_autopairs = require('nvim-autopairs.completion.cmp')
    -- local cmp = require('cmp')
    -- cmp.event:on(
    --   'confirm_done',
    --   cmp_autopairs.on_confirm_done()
    -- )
    -- Use cmdline & path source for ':' (if you enabled `native_menu`, this won't work anymore).
    cmp.setup.cmdline(":", {
      completion = {
        autocomplete = false,
      },
      mapping = cmp.mapping.preset.cmdline({
        -- Your configuration here.
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm(),
        ["<Tab>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        end, { "i", "c" }),
        ["<S-Tab>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item()
          else
            cmp.complete()
          end
        end),
      }),
      sources = cmp.config.sources({
        { name = "path" },
      }, {
        { name = "cmdline" },
      }),
    })
    cmp.setup.cmdline({ "/", "?" }, {
      mapping = cmp.mapping.preset.cmdline({
        -- Your configuration here.
        ["<C-n>"] = cmp.mapping(
          cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          { "i", "c" }
        ),
        ["<C-p>"] = cmp.mapping(
          cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          { "i", "c" }
        ),
        ["<C-b>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
        ["<C-e>"] = cmp.mapping.close(),
        ["<CR>"] = cmp.mapping.confirm(),
        ["<Tab>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_next_item()
          else
            cmp.complete()
          end
        end, { "i", "c" }),
        ["<S-Tab>"] = cmp.mapping(function()
          if cmp.visible() then
            cmp.select_prev_item()
          else
            cmp.complete()
          end
        end, { "i", "c" }),
      }),
      sources = cmp.config.sources({
        { name = "buffer" },
      }),
    })
    cmp.setup.filetype({ "dap-repl" }, {
      enabled = function()
        return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
          or require("cmp_dap").is_dap_buffer()
      end,
      sources = {
        { name = "dap", keyword_length = 1 },
      },
    })
    require("cmp_git").setup()
  end,
}
