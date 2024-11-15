local add, later = MiniDeps.add, MiniDeps.later
later(function()
  add({
    source = "nvim-orgmode/orgmode",
    depends = {
      "chipsenkbeil/org-roam.nvim",
    },
  })
  local config = {
    org_agenda_files = { "~/.archive/org/*" },
    notifications = {
      enabled = true,
    },
  }
  local default_notes_file = "~/.archive/org/refile.org"
  default_notes_file = vim.fn.expand(default_notes_file)
  if vim.fn.filereadable(default_notes_file) == 1 then
    config.org_default_notes_file = default_notes_file
  end
  require("orgmode").setup(config)
  require("org-roam").setup({
    directory = "~/.archive/org/roam",
  })
end)
