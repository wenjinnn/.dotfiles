local wezterm = require 'wezterm'
local mux = wezterm.mux
local act = wezterm.action

local vsc_colors = {
  vscNone = 'NONE',
  vscFront = '#D4D4D4',
  vscBack = '#1E1E1E',
  vscTabCurrent = '#1E1E1E',
  vscTabOther = '#2D2D2D',
  vscTabOutside = '#252526',
  vscLeftDark = '#252526',
  vscLeftMid = '#373737',
  vscLeftLight = '#636369',
  vscPopupFront = '#BBBBBB',
  vscPopupBack = '#272727',
  vscPopupHighlightBlue = '#004b72',
  vscPopupHighlightGray = '#343B41',
  vscSplitLight = '#898989',
  vscSplitDark = '#444444',
  vscSplitThumb = '#424242',
  vscCursorDarkDark = '#222222',
  vscCursorDark = '#51504F',
  vscCursorLight = '#AEAFAD',
  vscSelection = '#264F78',
  vscLineNumber = '#5A5A5A',
  vscDiffRedDark = '#4B1818',
  vscDiffRedLight = '#6F1313',
  vscDiffRedLightLight = '#FB0101',
  vscDiffGreenDark = '#373D29',
  vscDiffGreenLight = '#4B5632',
  vscSearchCurrent = '#515c6a',
  vscSearch = '#613315',
  vscGitAdded = '#81b88b',
  vscGitModified = '#e2c08d',
  vscGitDeleted = '#c74e39',
  vscGitRenamed = '#73c991',
  vscGitUntracked = '#73c991',
  vscGitIgnored = '#8c8c8c',
  vscGitStageModified = '#e2c08d',
  vscGitStageDeleted = '#c74e39',
  vscGitConflicting = '#e4676b',
  vscGitSubmodule = '#8db9e2',
  vscContext = '#404040',
  vscContextCurrent = '#707070',
  vscFoldBackground = '#202d39',
  -- Syntax colors
  vscGray = '#808080',
  vscViolet = '#646695',
  vscBlue = '#569CD6',
  vscDarkBlue = '#223E55',
  vscMediumBlue = '#18a2fe',
  vscLightBlue = '#9CDCFE',
  vscGreen = '#6A9955',
  vscBlueGreen = '#4EC9B0',
  vscLightGreen = '#B5CEA8',
  vscRed = '#F44747',
  vscOrange = '#CE9178',
  vscLightRed = '#D16969',
  vscYellowOrange = '#D7BA7D',
  vscYellow = '#DCDCAA',
  vscPink = '#C586C0'
}

local vsc_color_scheme = {
  foreground = vsc_colors.vscFront,
  background = vsc_colors.vscBack,
  cursor_bg = vsc_colors.vscCursorLight,
  cursor_border = vsc_colors.vscCursorLight,
  cursor_fg = vsc_colors.vscCursorDarkDark,
  selection_bg = vsc_colors.vscSelection,
  selection_fg = vsc_colors.Front,
  ansi = {
    '#000000', -- black
    '#cd3131', -- red
    '#0dbc79', -- green
    '#e5e510', -- yellow
    '#2472c8', -- blue
    '#bc3fbc', -- magenta/purple
    '#11a8cd', -- cyan
    '#e5e5e5', -- white
  },
  brights = {
    '#666666', -- black
    '#f14c4c', -- red
    '#23d18b', -- green
    '#f5f543', -- yellow
    '#3b8eea', -- blue
    '#d670d6', -- magenta/purple
    '#29b8db', -- cyan
    '#e5e5e5', -- white
  },
  tab_bar = {
    background = vsc_colors.vscTabOutside,
    active_tab = {
      bg_color = '#0a7aca',
      fg_color = '#ffffff',
    },
    inactive_tab = {
      bg_color = '#262626',
      fg_color = '#666666',
    },
    inactive_tab_hover = {
      bg_color = '#262626',
      fg_color = '#666666',
    },
  },
  visual_bell = vsc_colors.vscFront,
  -- indexed = {
  --    [16] = mocha.peach,
  --    [17] = mocha.rosewater,
  -- },
  scrollbar_thumb = vsc_colors.vscCursorDark,
  split = vsc_colors.vscSplitDark,
  compose_cursor = vsc_colors.vscFront, -- nightbuild only
}

wezterm.on(
  'format-tab-title',
  function(tab, tabs, panes, config, hover, max_width)
    local zoomed = ''
    if tab.active_pane.is_zoomed then
      zoomed = ' [Z]'
    end

    if tab.is_active then
      return {
        { Attribute = { Intensity = "Bold" } },
        { Text = ' ' .. tab.tab_index + 1 .. ' ' .. tab.active_pane.title .. zoomed .. ' ' },
      }
    end
    return ' ' .. tab.tab_index + 1 .. ' ' .. tab.active_pane.title .. zoomed .. ' '
  end
)

wezterm.on('gui-startup', function(cmd)
  local tab, pane, window = mux.spawn_window(cmd or {})
  window:gui_window():maximize()
end)

wezterm.on('update-status', function(window, pane)
  -- Each element holds the text for a cell in a "powerline" style << fade
  local cells = {}

  -- Figure out the cwd and host of the current pane.
  -- This will pick up the hostname for the remote host if your
  -- shell is using OSC 7 on the remote host.
  local cwd_uri = pane:get_current_working_dir()
  if cwd_uri then
    local cwd = ''
    local hostname = ''

    if type(cwd_uri) == 'userdata' then
      -- Running on a newer version of wezterm and we have
      -- a URL object here, making this simple!

      cwd = cwd_uri.file_path
      hostname = cwd_uri.host or wezterm.hostname()
    else
      -- an older version of wezterm, 20230712-072601-f4abf8fd or earlier,
      -- which doesn't have the Url object
      cwd_uri = cwd_uri:sub(8)
      local slash = cwd_uri:find '/'
      if slash then
        hostname = cwd_uri:sub(1, slash - 1)
        -- and extract the cwd from the uri, decoding %-encoding
        cwd = cwd_uri:sub(slash):gsub('%%(%x%x)', function(hex)
          return string.char(tonumber(hex, 16))
        end)
      end
    end

    -- Remove the domain name portion of the hostname
    local dot = hostname:find '[.]'
    if dot then
      hostname = hostname:sub(1, dot - 1)
    end
    if hostname == '' then
      hostname = wezterm.hostname()
    end

    table.insert(cells, cwd)
    table.insert(cells, hostname)
  end

  -- I like my date/time in this style: "Wed Mar 3 08:14"
  local date = wezterm.strftime '%a %b %-d %H:%M:%S'
  table.insert(cells, date)

  -- An entry for each battery (typically 0 or 1 battery)
  for _, b in ipairs(wezterm.battery_info()) do
    table.insert(cells, string.format('%.0f%%', b.state_of_charge * 100))
  end

  -- Foreground color for the text across the fade
  local text_fg = '#D4D4D4'

  -- Color palette for the backgrounds of each cell
  local colors = {
    { fg = '#D4D4D4', bg = '#262626'},
    { fg = '#FFFFFF', bg = '#f44747'},
    { fg = '#000000', bg = '#FFFFFF'},
    { fg = '#262626', bg = '#ddb6f2' },
  }

  -- The elements to be formatted
  local elements = {}
  -- How many cells have been formatted
  local num_cells = 0

  -- Translate a cell into elements
  function push(text, is_last)
    local cell_no = num_cells + 1
    table.insert(elements, { Foreground = { Color = colors[cell_no].fg } })
    table.insert(elements, { Background = { Color = colors[cell_no].bg } })
    table.insert(elements, { Attribute = { Intensity = "Bold" } })
    table.insert(elements, { Text = ' ' .. text .. ' ' })
    num_cells = num_cells + 1
  end

  while #cells > 0 do
    local cell = table.remove(cells, 1)
    push(cell, #cells == 0)
  end
  local workspace = window:active_workspace()
  local domain = pane:get_domain_name()

  window:set_right_status(wezterm.format(elements))
  window:set_left_status(wezterm.format(
    {
      { Foreground = { Color = '#262626' } },
      { Background = { Color = '#ffaf00' } },
      { Attribute = { Intensity = "Bold" } },
      { Text = ' ' .. workspace .. ' ' },
      { Foreground = { Color = '#262626' } },
      { Background = { Color = '#4ec9b0' } },
      { Attribute = { Intensity = "Bold" } },
      { Text = ' ' .. domain .. ' ' }
    }
  ))
end)

return {
  leader                       = { key = 'q', mods = 'CTRL' },
  unix_domains                 = {
    {
      name = 'unix',
    },
  },
  -- This causes `wezterm` to act as though it was started as
  -- `wezterm connect unix` by default, connecting to the unix
  -- domain on startup.
  -- If you prefer to connect manually, leave out this line.
  -- default_gui_startup_args     = { 'connect', 'unix' },
  default_domain     = 'unix',
  -- This causes `wezterm` to act as though it was started as
  -- `wezterm connect unix` by default, connecting to the unix
  -- domain on startup.
  -- If you prefer to connect manually, leave out this line.
  -- color_scheme                 = "VSCodeDark",
  colors                       = vsc_color_scheme,
  -- default_domain            = 'unix',
  use_fancy_tab_bar            = false,
  hide_tab_bar_if_only_one_tab = false,
  window_decorations           = "RESIZE",
  tab_bar_at_bottom            = true,
  scrollback_lines             = 20000,
  enable_scroll_bar            = false,
  window_background_opacity    = 0.90,
  text_background_opacity      = 0.90,
  window_padding               = {
    left = 0,
    right = 0,
    top = 0,
    bottom = 0,
  },
  font                         = wezterm.font 'FiraCode Nerd Font Mono',
  font_size                    = 11.0,
  term                         = 'wezterm',
  harfbuzz_features            = { 'calt=0', 'clig=0', 'liga=0' },
  color_schemes                = {
    ['VSCodeDark'] = vsc_color_scheme
  },
  disable_default_key_bindings = true,
  keys                         = {
    { key = 'm',     mods = 'LEADER',     action = wezterm.action.ShowLauncher },
    { key = 'Enter', mods = 'ALT',        action = act.ToggleFullScreen },
    { key = '!',     mods = 'LEADER',     action = act.ActivateTab(0) },
    { key = '-',     mods = 'LEADER',     action = act.SplitVertical { domain = 'CurrentPaneDomain' } },
    { key = '\\',    mods = 'LEADER',     action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
    { key = '0',     mods = 'SHIFT|CTRL', action = act.ResetFontSize },
    { key = '1',     mods = 'LEADER',     action = act.ActivateTab(0) },
    { key = '2',     mods = 'LEADER',     action = act.ActivateTab(1) },
    { key = '3',     mods = 'LEADER',     action = act.ActivateTab(2) },
    { key = '4',     mods = 'LEADER',     action = act.ActivateTab(3) },
    { key = '5',     mods = 'LEADER',     action = act.ActivateTab(4) },
    { key = '6',     mods = 'LEADER',     action = act.ActivateTab(5) },
    { key = '7',     mods = 'LEADER',     action = act.ActivateTab(6) },
    { key = '8',     mods = 'LEADER',     action = act.ActivateTab(7) },
    { key = '9',     mods = 'LEADER',     action = act.ActivateTab(-1) },
    { key = '0',     mods = 'LEADER',     action = act.ActivateTab(1) },
    { key = '=',     mods = 'CTRL', action = act.IncreaseFontSize },
    { key = '-',     mods = 'CTRL', action = act.DecreaseFontSize },
    { key = '[',     mods = 'LEADER',     action = act.ActivateTabRelative(-1) },
    { key = ']',     mods = 'LEADER',     action = act.ActivateTabRelative(1) },
    { key = 'c',     mods = 'SHIFT|CTRL', action = act.CopyTo 'Clipboard' },
    { key = 'f',     mods = 'SHIFT|CTRL', action = act.Search 'CurrentSelectionOrEmptyString' },
    { key = 'k',     mods = 'SHIFT|CTRL', action = act.ClearScrollback 'ScrollbackOnly' },
    { key = 'l',     mods = 'SHIFT|CTRL', action = act.ShowDebugOverlay },
    { key = 'm',     mods = 'SHIFT|CTRL', action = act.Hide },
    { key = 'n',     mods = 'LEADER',     action = act.SpawnWindow },
    { key = 'p',     mods = 'SHIFT|CTRL', action = act.ActivateCommandPalette },
    { key = 'r',     mods = 'LEADER',     action = act.ReloadConfiguration },
    { key = 't',     mods = 'LEADER',     action = act.SpawnTab 'CurrentPaneDomain' },
    { key = 'c',     mods = 'LEADER',     action = act.SpawnTab 'CurrentPaneDomain' },
    {
      key = 'u',
      mods = 'SHIFT|CTRL',
      action = act.CharSelect { copy_on_select = true, copy_to =
      'ClipboardAndPrimarySelection' }
    },
    { key = 'v',          mods = 'SHIFT|CTRL',     action = act.PasteFrom 'Clipboard' },
    { key = 'w',          mods = 'LEADER',         action = act.CloseCurrentTab { confirm = true } },
    { key = 'x',          mods = 'LEADER',         action = act.CloseCurrentPane { confirm = true } },
    { key = 'v',          mods = 'LEADER',         action = act.ActivateCopyMode },
    { key = 'z',          mods = 'LEADER',         action = act.TogglePaneZoomState },
    { key = 'q',          mods = 'LEADER',         action = act.PaneSelect },
    { key = 'h',          mods = 'LEADER',         action = act.ActivatePaneDirection 'Left' },
    { key = 'j',          mods = 'LEADER',         action = act.ActivatePaneDirection 'Down' },
    { key = 'k',          mods = 'LEADER',         action = act.ActivatePaneDirection 'Up' },
    { key = 'l',          mods = 'LEADER',         action = act.ActivatePaneDirection 'Right' },
    { key = 'phys:Space', mods = 'SHIFT|CTRL',     action = act.QuickSelect },
    { key = 'PageUp',     mods = 'SHIFT',          action = act.ScrollByPage(-1) },
    { key = 'PageUp',     mods = 'CTRL',           action = act.ActivateTabRelative(-1) },
    { key = 'PageUp',     mods = 'SHIFT|CTRL',     action = act.MoveTabRelative(-1) },
    { key = 'PageDown',   mods = 'SHIFT',          action = act.ScrollByPage(1) },
    { key = 'PageDown',   mods = 'CTRL',           action = act.ActivateTabRelative(1) },
    { key = 'PageDown',   mods = 'SHIFT|CTRL',     action = act.MoveTabRelative(1) },
    { key = 'LeftArrow',  mods = 'SHIFT|CTRL',     action = act.ActivatePaneDirection 'Left' },
    { key = 'LeftArrow',  mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Left', 1 } },
    { key = 'RightArrow', mods = 'SHIFT|CTRL',     action = act.ActivatePaneDirection 'Right' },
    { key = 'RightArrow', mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Right', 1 } },
    { key = 'UpArrow',    mods = 'SHIFT|CTRL',     action = act.ActivatePaneDirection 'Up' },
    { key = 'UpArrow',    mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Up', 1 } },
    { key = 'DownArrow',  mods = 'SHIFT|CTRL',     action = act.ActivatePaneDirection 'Down' },
    { key = 'DownArrow',  mods = 'SHIFT|ALT|CTRL', action = act.AdjustPaneSize { 'Down', 1 } },
    { key = 'Insert',     mods = 'SHIFT',          action = act.PasteFrom 'PrimarySelection' },
    { key = 'Insert',     mods = 'CTRL',           action = act.CopyTo 'PrimarySelection' },
    { key = 'Copy',       mods = 'NONE',           action = act.CopyTo 'Clipboard' },
    { key = 'Paste',      mods = 'NONE',           action = act.PasteFrom 'Clipboard' },
  },
  key_tables                   = {
    copy_mode = {
      { key = 'Tab',    mods = 'NONE',  action = act.CopyMode 'MoveForwardWord' },
      { key = 'Tab',    mods = 'SHIFT', action = act.CopyMode 'MoveBackwardWord' },
      { key = 'Enter',  mods = 'NONE',  action = act.CopyMode 'MoveToStartOfNextLine' },
      { key = 'Escape', mods = 'NONE',  action = act.CopyMode 'Close' },
      { key = 'Space',  mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Cell' } },
      { key = '$',      mods = 'NONE',  action = act.CopyMode 'MoveToEndOfLineContent' },
      { key = '$',      mods = 'SHIFT', action = act.CopyMode 'MoveToEndOfLineContent' },
      { key = ',',      mods = 'NONE',  action = act.CopyMode 'JumpReverse' },
      { key = '0',      mods = 'NONE',  action = act.CopyMode 'MoveToStartOfLine' },
      { key = ';',      mods = 'NONE',  action = act.CopyMode 'JumpAgain' },
      { key = 'F',      mods = 'NONE',  action = act.CopyMode { JumpBackward = { prev_char = false } } },
      { key = 'F',      mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = false } } },
      { key = 'G',      mods = 'NONE',  action = act.CopyMode 'MoveToScrollbackBottom' },
      { key = 'G',      mods = 'SHIFT', action = act.CopyMode 'MoveToScrollbackBottom' },
      { key = 'H',      mods = 'NONE',  action = act.CopyMode 'MoveToViewportTop' },
      { key = 'H',      mods = 'SHIFT', action = act.CopyMode 'MoveToViewportTop' },
      { key = 'L',      mods = 'NONE',  action = act.CopyMode 'MoveToViewportBottom' },
      { key = 'L',      mods = 'SHIFT', action = act.CopyMode 'MoveToViewportBottom' },
      { key = 'M',      mods = 'NONE',  action = act.CopyMode 'MoveToViewportMiddle' },
      { key = 'M',      mods = 'SHIFT', action = act.CopyMode 'MoveToViewportMiddle' },
      { key = 'O',      mods = 'NONE',  action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
      { key = 'O',      mods = 'SHIFT', action = act.CopyMode 'MoveToSelectionOtherEndHoriz' },
      { key = 'T',      mods = 'NONE',  action = act.CopyMode { JumpBackward = { prev_char = true } } },
      { key = 'T',      mods = 'SHIFT', action = act.CopyMode { JumpBackward = { prev_char = true } } },
      { key = 'V',      mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Line' } },
      { key = 'V',      mods = 'SHIFT', action = act.CopyMode { SetSelectionMode = 'Line' } },
      { key = '^',      mods = 'NONE',  action = act.CopyMode 'MoveToStartOfLineContent' },
      { key = '^',      mods = 'SHIFT', action = act.CopyMode 'MoveToStartOfLineContent' },
      { key = 'b',      mods = 'NONE',  action = act.CopyMode 'MoveBackwardWord' },
      { key = 'b',      mods = 'ALT',   action = act.CopyMode 'MoveBackwardWord' },
      { key = 'b',      mods = 'CTRL',  action = act.CopyMode 'PageUp' },
      { key = 'c',      mods = 'CTRL',  action = act.CopyMode 'Close' },
      { key = 'd',      mods = 'CTRL',  action = act.CopyMode { MoveByPage = (0.5) } },
      { key = 'e',      mods = 'NONE',  action = act.CopyMode 'MoveForwardWordEnd' },
      { key = 'f',      mods = 'NONE',  action = act.CopyMode { JumpForward = { prev_char = false } } },
      { key = 'f',      mods = 'ALT',   action = act.CopyMode 'MoveForwardWord' },
      { key = 'f',      mods = 'CTRL',  action = act.CopyMode 'PageDown' },
      { key = 'g',      mods = 'NONE',  action = act.CopyMode 'MoveToScrollbackTop' },
      { key = 'g',      mods = 'CTRL',  action = act.CopyMode 'Close' },
      { key = 'h',      mods = 'NONE',  action = act.CopyMode 'MoveLeft' },
      { key = 'j',      mods = 'NONE',  action = act.CopyMode 'MoveDown' },
      { key = 'k',      mods = 'NONE',  action = act.CopyMode 'MoveUp' },
      { key = 'l',      mods = 'NONE',  action = act.CopyMode 'MoveRight' },
      { key = 'm',      mods = 'ALT',   action = act.CopyMode 'MoveToStartOfLineContent' },
      { key = 'o',      mods = 'NONE',  action = act.CopyMode 'MoveToSelectionOtherEnd' },
      { key = 'q',      mods = 'NONE',  action = act.CopyMode 'Close' },
      { key = 't',      mods = 'NONE',  action = act.CopyMode { JumpForward = { prev_char = true } } },
      { key = 'u',      mods = 'CTRL',  action = act.CopyMode { MoveByPage = (-0.5) } },
      { key = 'v',      mods = 'NONE',  action = act.CopyMode { SetSelectionMode = 'Cell' } },
      { key = 'v',      mods = 'CTRL',  action = act.CopyMode { SetSelectionMode = 'Block' } },
      { key = 'w',      mods = 'NONE',  action = act.CopyMode 'MoveForwardWord' },
      {
        key = 'y',
        mods = 'NONE',
        action = act.Multiple { { CopyTo = 'ClipboardAndPrimarySelection' }, {
          CopyMode = 'Close' } }
      },
      { key = 'PageUp',     mods = 'NONE', action = act.CopyMode 'PageUp' },
      { key = 'PageDown',   mods = 'NONE', action = act.CopyMode 'PageDown' },
      { key = 'End',        mods = 'NONE', action = act.CopyMode 'MoveToEndOfLineContent' },
      { key = 'Home',       mods = 'NONE', action = act.CopyMode 'MoveToStartOfLine' },
      { key = 'LeftArrow',  mods = 'NONE', action = act.CopyMode 'MoveLeft' },
      { key = 'LeftArrow',  mods = 'ALT',  action = act.CopyMode 'MoveBackwardWord' },
      { key = 'RightArrow', mods = 'NONE', action = act.CopyMode 'MoveRight' },
      { key = 'RightArrow', mods = 'ALT',  action = act.CopyMode 'MoveForwardWord' },
      { key = 'UpArrow',    mods = 'NONE', action = act.CopyMode 'MoveUp' },
      { key = 'DownArrow',  mods = 'NONE', action = act.CopyMode 'MoveDown' },
    },
    search_mode = {
      { key = 'Enter',     mods = 'NONE', action = act.CopyMode 'PriorMatch' },
      { key = 'Escape',    mods = 'NONE', action = act.CopyMode 'Close' },
      { key = 'n',         mods = 'CTRL', action = act.CopyMode 'NextMatch' },
      { key = 'p',         mods = 'CTRL', action = act.CopyMode 'PriorMatch' },
      { key = 'r',         mods = 'CTRL', action = act.CopyMode 'CycleMatchType' },
      { key = 'u',         mods = 'CTRL', action = act.CopyMode 'ClearPattern' },
      { key = 'PageUp',    mods = 'NONE', action = act.CopyMode 'PriorMatchPage' },
      { key = 'PageDown',  mods = 'NONE', action = act.CopyMode 'NextMatchPage' },
      { key = 'UpArrow',   mods = 'NONE', action = act.CopyMode 'PriorMatch' },
      { key = 'DownArrow', mods = 'NONE', action = act.CopyMode 'NextMatch' },
    },
  }
}
