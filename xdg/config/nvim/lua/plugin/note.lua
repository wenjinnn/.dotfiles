local add, later = MiniDeps.add, MiniDeps.later

-- obsidian.nvim for note-taking
later(function()
  add('obsidian-nvim/obsidian.nvim')
  local archive_path = os.getenv('ARCHIVE')
  local note_path = archive_path and archive_path .. '/note' or '~/.archive/note'
  require('obsidian').setup({
    workspaces = {
      {
        name = 'life',
        path = note_path .. '/life',
      },
      {
        name = 'work',
        path = note_path .. '/work',
      },
    },
  })
end)
