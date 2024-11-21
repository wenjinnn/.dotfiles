{
  programs.zellij = {
    enable = true;
    settings = {
      ui.pane_frames.hide_session_name = true;
      pane_frames = false;
      serialize_pane_viewport = true;
      default_layout = "compact";
      default_mode = "locked";
      simplified_ui = true;
      keybinds = {
        locked = {
          "bind \"Ctrl q\"" = {
            SwitchToMode = "Normal";
          };
        };
        normal = {
          "bind \"Ctrl q\"" = {
            SwitchToMode = "Locked";
          };
        };
        "shared_except \"locked\" \"renametab\" \"renamepane\"" = {
          "unbind \"Ctrl q\"" = [];
          "bind \"Q\"" = {
            Quit = [];
          };
        };
      };
    };
  };
}
