{me, ...}: {
  programs.gnome-terminal = {
    enable = true;
    showMenubar = false;
    profile."2feb4282-c157-43f0-a9cf-90e58422cfc8" = {
      visibleName = me.username;
      font = "monospace 11";
      default = true;
      allowBold = true;
      boldIsBright = true;
      transparencyPercent = 90;
      showScrollbar = false;
    };
  };
}
