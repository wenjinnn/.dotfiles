local add, later = MiniDeps.add, MiniDeps.later

-- orgmode are better note taking for me :)
later(function()
  add({
    source = 'nvim-orgmode/orgmode',
    depends = {
      'chipsenkbeil/org-roam.nvim',
    },
  })
  local archive_path = os.getenv('ARCHIVE')
  local org_path = archive_path and archive_path .. '/org' or '~/.archive/org'
  require('orgmode').setup({
    org_agenda_files = { org_path .. '/*' },
    org_default_notes_file = org_path .. '/refile.org',
    notifications = {
      enabled = true,
    },
  })
  require('org-roam').setup({
    directory = org_path .. '/roam',
  })
end)
