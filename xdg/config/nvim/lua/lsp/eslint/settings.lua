local node_path = os.getenv("ESLINT_LIBRARY")
return {
  format = { enable = true },
  autoFixOnSave = true,
  codeActionsOnSave = {
    mode = "all",
    rules = { "!debugger", "!no-only-tests/*" },
  },
  nodePath = node_path or "",
  lintTask = {
    enable = true,
  },
}
