local M = {}

function M.setup_terminal_color(base_color)
  local palette = require("mini.hues").make_palette(base_color)
  vim.g.terminal_color_8 = palette.bg_mid2
  vim.g.terminal_color_9 = palette.red_mid2
  vim.g.terminal_color_10 = palette.green_mid2
  vim.g.terminal_color_11 = palette.yellow_mid2
  vim.g.terminal_color_12 = palette.azure_mid2
  vim.g.terminal_color_13 = palette.purple_mid2
  vim.g.terminal_color_14 = palette.cyan_mid2
  vim.g.terminal_color_15 = palette.fg_mid2
end

function M.override_hl(name, opts)
  local hl = vim.api.nvim_get_hl(0, { name = name })
  hl = vim.tbl_deep_extend("force", hl, opts)
  vim.api.nvim_set_hl(0, name, hl)
end

function M.setup_mini_hues_hl()
  vim.api.nvim_set_hl(0, "@lsp.type.interface", { link = "@interface" })
  vim.api.nvim_set_hl(0, "@interface", { link = "@constant" })
  vim.api.nvim_set_hl(0, "@lsp.type.class", { link = "@punctuation" })
  M.override_hl("Visual", { bold = true })
  M.override_hl("Comment", { italic = true })
  M.override_hl("DiagnosticError", { italic = true })
  M.override_hl("DiagnosticWarn", { italic = true })
  M.override_hl("DiagnosticInfo", { italic = true })
  M.override_hl("DiagnosticHint", { italic = true })
  M.override_hl("DiagnosticOk", { italic = true })
end
return M