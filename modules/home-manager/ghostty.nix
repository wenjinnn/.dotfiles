{
  programs.ghostty = {
    enable = true;
    systemd.enable = true;
    enableBashIntegration = true;
    settings = {
      theme = "Gruvbox Dark Hard";
      font-size = 11;
      font-family = "CaskaydiaCove Nerd Font";
      window-padding-y = "0,0";
      window-padding-x = "0,0";
      window-padding-balance = true;
    };
  };
}
