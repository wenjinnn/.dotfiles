local add, later = MiniDeps.add, MiniDeps.later

-- obsidian.nvim for note-taking
later(function()
  add('obsidian-nvim/obsidian.nvim')
  local note_path = os.getenv('NOTE') or '~/.note'
  require('obsidian').setup({
    workspaces = {
      { name = 'life', path = note_path .. '/life' },
      { name = 'work', path = note_path .. '/work' },
    },
  })
end)
