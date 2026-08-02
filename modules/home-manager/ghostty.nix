{
  programs.ghostty = {
    enable = true;
    systemd.enable = true;
    enableBashIntegration = true;
    settings = {
      # theme = "Gruvbox Dark Hard";
      # font-size = 12;
      # font-family = "Maple Mono NF";
      window-padding-y = "0,0";
      window-padding-x = "0,0";
      window-padding-balance = true;
      keybind = [
        "alt+backspace=text:\\x1b\\x7f"
      ];
    };
  };
}
