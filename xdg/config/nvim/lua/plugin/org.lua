local not_vscode = require("util").not_vscode
return {
  "nvim-orgmode/orgmode",
  cond = not_vscode,
  event = "BufReadPre",
  dependencies = {
    {
      "chipsenkbeil/org-roam.nvim",
      opts = {
        directory = "~/project/my/archive/org/",
      },
    },
  },
  opts = function()
    require("orgmode").setup_ts_grammar()
    local config = {
      org_agenda_files = { "~/project/my/archive/org/*" },
      notifications = {
        enabled = true,
      },
    }
    local default_notes_file = "~/project/my/archive/org/refile.org"
    default_notes_file = vim.fn.expand(default_notes_file)
    if vim.fn.filereadable(default_notes_file) == 1 then
      config.org_default_notes_file = default_notes_file
    end
    return config
  end,
}
