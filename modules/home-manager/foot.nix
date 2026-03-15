{ lib, config, ... }:
{
  # foot
  programs.foot = {
    enable = true;
    settings = {
      main = {
        include = "${config.home.homeDirectory}/.config/foot/dank-colors.ini";
        font = "monospace:size=11";
        selection-target = "both";
      };
      key-bindings = {
        scrollback-up-page = "Control+Shift+b";
        scrollback-down-page = "Control+Shift+f";
      };
      search-bindings = {
        scrollback-up-page = "Control+Shift+b";
        scrollback-down-page = "Control+Shift+f";
      };
      scrollback = {
        lines = 10000;
      };
    };
  };
}
