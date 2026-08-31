local M = {}

-- Setup 16 colors for terminal, otherwise some colors will looks strange.
function M.setup_terminal_color(base_color)
  local palette = require('mini.hues').make_palette(base_color)
  vim.g.terminal_color_0 = palette.bg_mid2
  vim.g.terminal_color_1 = palette.red_mid2
  vim.g.terminal_color_2 = palette.green_mid2
  vim.g.terminal_color_3 = palette.yellow_mid2
  vim.g.terminal_color_4 = palette.azure_mid2
  vim.g.terminal_color_5 = palette.purple_mid2
  vim.g.terminal_color_6 = palette.cyan_mid2
  vim.g.terminal_color_7 = palette.fg_mid2
  vim.g.terminal_color_8 = palette.bg_mid
  vim.g.terminal_color_9 = palette.red_mid
  vim.g.terminal_color_10 = palette.green_mid
  vim.g.terminal_color_11 = palette.yellow_mid
  vim.g.terminal_color_12 = palette.azure_mid
  vim.g.terminal_color_13 = palette.purple_mid
  vim.g.terminal_color_14 = palette.cyan_mid
  vim.g.terminal_color_15 = palette.fg_mid
end

-- Make override highlight easier
function M.override_hl(name, opts)
  local hl = vim.api.nvim_get_hl(0, { name = name })
  hl = vim.tbl_deep_extend('force', hl, opts)
  vim.api.nvim_set_hl(0, name, hl)
end

-- Some personal preferences for highlighting settings
function M.setup_hl()
  vim.api.nvim_set_hl(0, '@lsp.type.interface', { link = 'Constant' })
  vim.api.nvim_set_hl(0, '@keyword', { link = 'Keyword' })
  vim.api.nvim_set_hl(0, '@keyword.operator', { link = '@keyword' })
  vim.api.nvim_set_hl(0, '@keyword.modifier', { link = '@keyword' })
  vim.api.nvim_set_hl(0, '@lsp.type.modifier', { link = '@keyword' })
  vim.api.nvim_set_hl(0, '@lsp.type.class', { link = 'Type' })
  vim.api.nvim_set_hl(0, 'MiniStatusLineFilename', { link = 'Normal' })
  vim.api.nvim_set_hl(0, 'MiniIconsOrange', { link = 'Constant' })
  vim.api.nvim_set_hl(0, 'MiniIconsGreen', { link = 'String' })
  vim.api.nvim_set_hl(0, 'MiniIconsBlue', { link = 'Directory' })
  vim.api.nvim_set_hl(0, 'MiniIconsRed', { link = 'Character' })
  vim.api.nvim_set_hl(0, 'MiniIconsAzure', { link = 'Special' })
  vim.api.nvim_set_hl(0, 'MiniIconsCyan', { link = 'OkMsg' })
  vim.api.nvim_set_hl(0, 'MiniIconsYellow', { link = 'Type' })
  vim.api.nvim_set_hl(0, 'MiniIconsPurple', { link = 'Conditional' })
  vim.api.nvim_set_hl(0, 'MinuetDuetAdd', { link = 'DiffAdd' })
  vim.api.nvim_set_hl(0, 'MinuetDuetDelete', { link = 'DiffDelete' })
  vim.api.nvim_set_hl(0, 'MinuetDuetComment', { link = 'Comment' })
  vim.api.nvim_set_hl(0, 'MinuetDuetCursor', { link = 'IncSearch' })
  vim.api.nvim_set_hl(0, 'MinuetVirtualText', { link = 'Comment' })
  vim.api.nvim_set_hl(0, 'LspKindMinuet', { link = 'LspKindText' })
  vim.api.nvim_set_hl(0, 'NormalFloat', { link = 'Normal' })
  vim.api.nvim_set_hl(0, 'PmenuSel', { reverse = true, blend = 0 })
  M.override_hl('WinSeparator', { bg = 'NONE' })
  M.override_hl('SignColumn', { bg = 'NONE' })
  M.override_hl('LineNr', { bg = 'NONE' })
  M.override_hl('LineNrAbove', { bg = 'NONE' })
  M.override_hl('LineNrBelow', { bg = 'NONE' })
  M.override_hl('CursorLineNr', { bg = 'NONE' })
  M.override_hl('CursorLineSign', { bg = 'NONE' })
  M.override_hl('MiniDiffSignAdd', { bg = 'NONE' })
  M.override_hl('MiniDiffSignChange', { bg = 'NONE' })
  M.override_hl('MiniDiffSignDelete', { bg = 'NONE' })
  M.override_hl('DiagnosticFloatingError', { bg = 'NONE' })
  M.override_hl('DiagnosticFloatingWarn', { bg = 'NONE' })
  M.override_hl('DiagnosticFloatingInfo', { bg = 'NONE' })
  M.override_hl('DiagnosticFloatingHint', { bg = 'NONE' })
  M.override_hl('DiagnosticFloatingOk', { bg = 'NONE' })
  M.override_hl('@comment', { italic = true })
  M.override_hl('Visual', { bold = true })
  M.override_hl('Keyword', { bold = true })
  M.override_hl('Comment', { italic = true })
  M.override_hl('DiagnosticError', { italic = true })
  M.override_hl('DiagnosticWarn', { italic = true })
  M.override_hl('DiagnosticInfo', { italic = true })
  M.override_hl('DiagnosticHint', { italic = true })
  M.override_hl('DiagnosticOk', { italic = true })
  M.override_hl('NonText', { italic = true })
  M.override_hl('LspInlayHint', { italic = true })
end

-- A wrapper for above functions
function M.setup_wenvim_color(base_color)
  M.setup_terminal_color(base_color)
end

return M
