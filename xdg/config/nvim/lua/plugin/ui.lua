local not_vscode = require("util").not_vscode

return {
  {
    "echasnovski/mini.starter",
    event = "VimEnter",
    cond = not_vscode,
    opts = function()
      local starter = require("mini.starter")
      return {
        items = {
          starter.sections.sessions(5, true),
          starter.sections.recent_files(5, true, true),
          starter.sections.recent_files(5, false, true),
          {
            name = "Agenda",
            action = "lua require'orgmode.api.agenda'.agenda()",
            section = "Org",
          },
          starter.sections.builtin_actions(),
        },
      }
    end,
  },
  {
    "echasnovski/mini.icons",
    opts = {},
    event = "VeryLazy",
    lazy = true,
    config = function(_, opts)
      require("mini.icons").setup(opts)
      MiniIcons.mock_nvim_web_devicons()
    end,
  },
  {
    "echasnovski/mini.notify",
    lazy = true,
    event = "BufRead",
    opts = {},
    keys = {
      {
        "<leader>N",
        "<cmd>lua MiniNotify.show_history()<CR>",
        desc = "Notify history",
      },
    },
  },
  { "echasnovski/mini.statusline", opts = {}, event = "UIEnter" },
  { "echasnovski/mini.tabline", opts = {}, event = "UIEnter" },
  {
    "echasnovski/mini.indentscope",
    event = "BufRead",
    lazy = true,
    cond = not_vscode,
    opts = function()
      return {
        draw = {
          animation = require("mini.indentscope").gen_animation.none(),
        },
      }
    end,
  },
  {
    "echasnovski/mini.hipatterns",
    event = "BufRead",
    cond = not_vscode,
    opts = function()
      local hipatterns = require("mini.hipatterns")
      local hi_words = require("mini.extra").gen_highlighter.words
      return {
        highlighters = {
          fixme = hi_words({ "FIXME", "Fixme", "fixme" }, "MiniHipatternsFixme"),
          fix = hi_words({ "FIX", "Fix", "fix" }, "MiniHipatternsFixme"),
          hack = hi_words({ "HACK", "Hack", "hack" }, "MiniHipatternsHack"),
          todo = hi_words({ "TODO", "Todo", "todo" }, "MiniHipatternsTodo"),
          note = hi_words({ "NOTE", "Note", "note" }, "MiniHipatternsNote"),
          done = hi_words({ "DONE", "Done", "done" }, "MiniHipatternsNote"),
          hex_color = hipatterns.gen_highlighter.hex_color(),
        },
      }
    end,
  },
  {
    "echasnovski/mini.clue",
    event = "BufRead",
    cond = not_vscode,
    opts = function()
      local miniclue = require("mini.clue")
      local z_post_keys = { zl = "z", zh = "z", zL = "z", zH = "z" }
      local clue_z_keys = miniclue.gen_clues.z()
      for _, v in ipairs(clue_z_keys) do
        for key, postkeys in pairs(z_post_keys) do
          if v.keys == key then
            v.postkeys = postkeys
          end
        end
      end
      return {
        triggers = {
          -- Leader triggers
          { mode = "n", keys = "<Leader>" },
          { mode = "x", keys = "<Leader>" },

          -- Built-in completion
          { mode = "i", keys = "<C-x>" },

          -- `g` key
          { mode = "n", keys = "g" },
          { mode = "x", keys = "g" },

          -- Marks
          { mode = "n", keys = "'" },
          { mode = "n", keys = "`" },
          { mode = "x", keys = "'" },
          { mode = "x", keys = "`" },

          -- Registers
          { mode = "n", keys = '"' },
          { mode = "x", keys = '"' },
          { mode = "i", keys = "<C-r>" },
          { mode = "c", keys = "<C-r>" },

          -- Window commands
          { mode = "n", keys = "<C-w>" },

          -- `z` key
          { mode = "n", keys = "z" },
          { mode = "x", keys = "z" },

          -- mini.surround
          { mode = "n", keys = "s" },

          -- mini.bracketed
          { mode = "n", keys = "]" },
          { mode = "n", keys = "[" },

          { mode = "n", keys = "\\" },
          -- Operator-pending mode key
          { mode = "o", keys = "a" },
          { mode = "o", keys = "i" },
        },

        clues = {
          -- Enhance this by adding descriptions for <Leader> mapping groups
          miniclue.gen_clues.builtin_completion(),
          miniclue.gen_clues.g(),
          miniclue.gen_clues.marks(),
          miniclue.gen_clues.registers(),
          miniclue.gen_clues.windows({ submode_resize = true }),
          clue_z_keys,
        },
      }
    end,
  },
}
