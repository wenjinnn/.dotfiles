local add, later = MiniDeps.add, MiniDeps.later

-- obsidian.nvim for note-taking
later(function()
  add('obsidian-nvim/obsidian.nvim')
  -- setup obsidian.nvim only when NOTE env exists
  local note_path = vim.env.NOTE
  if note_path ~= nil then
    require('obsidian').setup({
      workspaces = {
        { name = 'life', path = note_path .. '/life' },
        { name = 'work', path = note_path .. '/work' },
      },
      legacy_commands = false,
      statusline = {
        enabled = false,
      },
    })
  end
end)
