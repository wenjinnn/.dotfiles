{
  programs.ghostty = {
    enable = true;
    systemd.enable = true;
    enableBashIntegration = true;
    settings = {
      theme = "dankcolors";
      font-size = 11;
      font-family = "monospace";
      window-padding-y = "0,0";
      window-padding-x = "0,0";
      window-padding-balance = true;
    };
  };
}
