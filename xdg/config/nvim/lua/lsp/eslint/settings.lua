return {
  format = { enable = true },
  autoFixOnSave = true,
  codeActionsOnSave = {
    mode = 'all',
    rules = { '!debugger', '!no-only-tests/*' },
  },
  lintTask = {
    enable = true,
  },
}
