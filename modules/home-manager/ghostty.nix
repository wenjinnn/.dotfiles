{
  programs.ghostty = {
    enable = true;
    systemd.enable = true;
    enableBashIntegration = true;
    settings = {
      theme = "dankcolors";
      font-size = 11;
      font-family = "monospace";
    };
  };
}
